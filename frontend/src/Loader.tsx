export function CoffeeMark({ className = "h-6 w-6" }: { className?: string }) {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" fill="currentColor" className={className} aria-hidden="true">
      <path d="M208,88v48a88,88,0,0,1-51.3,80H83.3A88,88,0,0,1,32,136V88Z" opacity="0.2" />
      <path d="M80,56V24a8,8,0,0,1,16,0V56a8,8,0,0,1-16,0Zm40,8a8,8,0,0,0,8-8V24a8,8,0,0,0-16,0V56A8,8,0,0,0,120,64Zm32,0a8,8,0,0,0,8-8V24a8,8,0,0,0-16,0V56A8,8,0,0,0,152,64Zm96,56v8a40,40,0,0,1-37.51,39.91,96.59,96.59,0,0,1-27,40.09H208a8,8,0,0,1,0,16H32a8,8,0,0,1,0-16H56.54A96.3,96.3,0,0,1,24,136V88a8,8,0,0,1,8-8H208A40,40,0,0,1,248,120ZM200,96H40v40a80.27,80.27,0,0,0,45.12,72h69.76A80.27,80.27,0,0,0,200,136Zm32,24a24,24,0,0,0-16-22.62V136a95.78,95.78,0,0,1-1.2,15A24,24,0,0,0,232,128Z" />
    </svg>
  );
}

export function Loader({ leaving = false }: { leaving?: boolean }) {
  return (
    <div className={`relative flex h-screen w-screen items-center justify-center overflow-hidden bg-[var(--background)] ${leaving ? "loader-exit" : ""}`}>
      <div className="z-10 flex flex-col items-center gap-6">
        <div className="relative flex h-20 w-20 items-center justify-center">
          <svg className="loader-ring absolute h-16 w-16" viewBox="0 0 60 60" style={{ overflow: "visible" }}>
            <circle
              cx="30"
              cy="30"
              r="22"
              fill="none"
              stroke="var(--accent-gold)"
              strokeWidth="2"
              strokeLinecap="round"
              strokeDasharray="60 78"
              style={{ filter: "drop-shadow(0 0 8px rgba(201, 168, 108, 0.45))" }}
            />
          </svg>
          <div className="loader-float relative flex items-center justify-center">
            <div className="absolute -top-3.5 flex w-full justify-center gap-1">
              <div className="loader-steam h-2 w-[1.5px] rounded-full bg-[var(--accent-gold)]/70 blur-[0.3px]" style={{ animationDelay: "0s" }} />
              <div className="loader-steam h-2.5 w-[1.5px] rounded-full bg-[var(--accent-gold)]/70 blur-[0.3px]" style={{ animationDelay: "0.45s" }} />
              <div className="loader-steam h-2 w-[1.5px] rounded-full bg-[var(--accent-gold)]/70 blur-[0.3px]" style={{ animationDelay: "0.9s" }} />
            </div>
            <CoffeeMark className="h-6 w-6 text-[var(--accent-gold)] drop-shadow-[0_0_6px_rgba(201,168,108,0.3)]" />
          </div>
        </div>
        <div className="relative overflow-hidden">
          <p className="loader-breathe text-[10px] font-bold uppercase text-[var(--text-muted)]">Loading Mocha</p>
        </div>
      </div>
    </div>
  );
}
