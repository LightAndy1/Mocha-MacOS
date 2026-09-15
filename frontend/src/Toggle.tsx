export function Toggle({ checked, onChange, label }: { checked: boolean; onChange: (v: boolean) => void; label: string }) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      onClick={() => onChange(!checked)}
      className={`relative h-6 w-11 shrink-0 rounded-full border transition-all duration-500 ease-[cubic-bezier(0.32,0.72,0,1)] active:scale-[0.96] ${
        checked
          ? "border-mocha-gold/50 bg-mocha-gold shadow-[0_0_16px_rgba(201,168,108,0.35),inset_0_1px_1px_rgba(255,255,255,0.3)]"
          : "border-white/10 bg-white/[0.07] shadow-[inset_0_1px_2px_rgba(0,0,0,0.4)]"
      }`}
    >
      <span
        aria-hidden
        className={`absolute top-1/2 h-5 w-5 rounded-full transition-all duration-500 ease-[cubic-bezier(0.16,1,0.3,1)] ${
          checked
            ? "left-[22px] -translate-y-1/2 bg-[#1a1410] shadow-[0_1px_4px_rgba(0,0,0,0.4)]"
            : "left-[2px] -translate-y-1/2 bg-mocha-secondary shadow-[inset_0_1px_1px_rgba(255,255,255,0.2)]"
        }`}
      />
    </button>
  );
}

export function SettingRow({ title, desc, checked, onChange }: { title: string; desc: string; checked: boolean; onChange: (v: boolean) => void }) {
  return (
    <div className="flex items-center justify-between gap-4 rounded-2xl border border-white/5 bg-white/[0.02] px-4 py-3.5">
      <div className="min-w-0">
        <div className="text-sm font-medium text-mocha-primary">{title}</div>
        <div className="mt-0.5 font-mono text-[11px] leading-relaxed text-mocha-muted">{desc}</div>
      </div>
      <Toggle checked={checked} onChange={onChange} label={title} />
    </div>
  );
}
