param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Files = @())

$ErrorActionPreference = 'Stop'
$AppId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
Add-Type -AssemblyName System.Web
$FolderName = 'Quick Share'
$script:ApiBase = $null
$script:AppUrl = $null
$script:ApiKey = $null

function Toast {
    param([string]$Title, [string]$Message)
    try {
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        $xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
        $texts = $xml.GetElementsByTagName('text')
        $texts.Item(0).AppendChild($xml.CreateTextNode($Title)) | Out-Null
        $texts.Item(1).AppendChild($xml.CreateTextNode($Message)) | Out-Null
        $toast = New-Object Windows.UI.Notifications.ToastNotification $xml
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId).Show($toast)
    } catch { }
}

function StatusCode($err) {
    $r = $err.Exception.Response
    if ($r) { [int]$r.StatusCode } else { 0 }
}

function Api {
    param([string]$Method, [string]$Path, $Body)
    $splat = @{
        Method      = $Method
        Uri         = "$script:ApiBase$Path"
        Headers     = @{ Authorization = "Bearer $script:ApiKey" }
        ContentType = 'application/json'
    }
    if ($null -ne $Body) { $splat.Body = ($Body | ConvertTo-Json -Depth 5 -Compress) }
    Invoke-RestMethod @splat
}

function Upload {
    param([string]$file)

    $name = Split-Path -Leaf $file
    $size = (Get-Item -LiteralPath $file).Length
    $mime = [Web.MimeMapping]::GetMimeMapping($file)
    $folderPath = "/$FolderName/"

    try {
        $r = Invoke-RestMethod -Method Post -Uri "$script:ApiBase/files" -Headers @{
                Authorization = "Bearer $script:ApiKey"
                'x-file-name' = $name
                'x-file-path' = $folderPath
                'x-file-type' = $mime
            } -ContentType $mime -InFile $file
        return $r.file.id
    } catch {
        if ((StatusCode $_) -ne 400) { throw }
    }

    $init = $null
    try {
        $init = Api Post '/files/multipart/init' @{
            originalName = $name
            size         = $size
            mimeType     = $mime
            path         = $folderPath
        }
        $chunk = [int64]$init.partSizeBytes
        if ($init.directPartUpload -and $init.directPartSizeBytes) { $chunk = [int64]$init.directPartSizeBytes }
        if ($chunk -le 0) { $chunk = 50MB }
        if (-not $init.directPartUpload) { throw "$name is on a node without direct part upload support" }
        $numParts = [int][Math]::Ceiling($size / $chunk)
        if ($numParts -lt 1) { $numParts = 1 }

        $presigned = Api Post '/files/multipart/presigned' @{
            uploadId     = $init.uploadId
            key          = $init.key
            nodeId       = $init.nodeId
            originalName = $init.originalName
            path         = $folderPath
            partNumbers  = @(1..$numParts)
        }

        $fs = [IO.File]::OpenRead($file)
        try {
            $parts = @(foreach ($u in $presigned.urls) {
                $offset = [int64]($u.partNumber - 1) * $chunk
                $len = [Math]::Min($chunk, $size - $offset)
                $bytes = New-Object byte[] $len
                [void]$fs.Seek($offset, 'Begin')
                [void]$fs.Read($bytes, 0, $len)
                $wc = New-Object System.Net.WebClient
                $wc.Headers['Content-Type'] = 'application/octet-stream'
                [void]$wc.UploadData($u.url, 'PUT', $bytes)
                @{ partNumber = $u.partNumber; etag = "$($wc.ResponseHeaders['ETag'])".Trim('"') }
            })
        } finally {
            $fs.Close()
        }

        $md5 = $null
        if ($size -le 200MB) {
            $md5 = (Get-FileHash -LiteralPath $file -Algorithm MD5).Hash.ToLower()
        }
        $done = Api Post '/files/multipart/complete' @{
            uploadId     = $init.uploadId
            key          = $init.key
            nodeId       = $init.nodeId
            originalName = $init.originalName
            path         = $folderPath
            mimeType     = $mime
            size         = $size
            parts        = $parts
            md5          = $md5
        }
        $done.file.id
    } catch {
        if ($init) {
            try {
                Api Post '/files/multipart/abort' @{
                    uploadId     = $init.uploadId
                    key          = $init.key
                    nodeId       = $init.nodeId
                    originalName = $init.originalName
                    path         = $folderPath
                } | Out-Null
            } catch { }
        }
        throw
    }
}

try {
    if (-not $Files) { throw 'No file selected' }

    $cfgPath = Join-Path $env:APPDATA 'mocha-desktop\config.json'
    if (-not (Test-Path -LiteralPath $cfgPath)) { throw 'Mocha Desktop is not configured (config.json missing)' }
    $cfg = Get-Content -LiteralPath $cfgPath -Raw | ConvertFrom-Json
    $base = if ($cfg.apiUrl) { $cfg.apiUrl } else { $cfg.appUrl }
    if (-not $base) { throw 'Mocha Desktop has no app URL set; open Mocha Desktop and sign in first' }
    $script:ApiBase = ($base.TrimEnd('/') -replace '/api$', '') + '/api'

    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class CredMan {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct CREDENTIAL {
        public int Flags; public int Type; public string TargetName; public string Comment;
        public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
        public int CredentialBlobSize; public IntPtr CredentialBlob; public int Persist;
        public int AttributeCount; public IntPtr Attributes; public string TargetAlias; public string UserName;
    }
    [DllImport("advapi32.dll", EntryPoint = "CredReadW", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern bool CredRead(string target, int type, int reserved, out IntPtr credPtr);
    [DllImport("advapi32.dll")]
    public static extern void CredFree(IntPtr cred);
}
"@
    $ptr = [IntPtr]::Zero
    if (-not [CredMan]::CredRead('mocha-desktop:api-key', 1, 0, [ref]$ptr)) {
        throw 'No Mocha Desktop API key in Windows Credential Manager; open Mocha Desktop and sign in first'
    }
    $cred = [Runtime.InteropServices.Marshal]::PtrToStructure($ptr, [type][CredMan+CREDENTIAL])
    $blob = New-Object byte[] $cred.CredentialBlobSize
    [Runtime.InteropServices.Marshal]::Copy($cred.CredentialBlob, $blob, 0, $cred.CredentialBlobSize)
    [CredMan]::CredFree($ptr)
    $script:ApiKey = [Text.Encoding]::UTF8.GetString($blob)

    try { Api Post '/files/folders' @{ path = '/'; name = $FolderName } | Out-Null } catch { }

    $lastLink = $null
    foreach ($f in $Files) {
        if ([IO.Directory]::Exists($f)) { continue }
        $name = Split-Path -Leaf $f
        try {
            $fileId = Upload $f
            $share = Api Post '/shares' @{ fileId = $fileId; expiresInHours = $null }
            $lastLink = "https://mocha.my/share/$($share.share.token)"
        } catch {
            Toast 'Quick Share failed' "$name : $($_.Exception.Message)"
        }
    }
    if ($lastLink) {
        Set-Clipboard -Value $lastLink
        Toast 'Quick Share' "$($name) uploaded - link copied to clipboard"
    }
} catch {
    Toast 'Quick Share failed' $_.Exception.Message
    exit 1
}
