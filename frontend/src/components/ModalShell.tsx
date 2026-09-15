import { useCallback, useEffect, useRef, useState, type ReactNode } from "react";

export function ModalShell({ label, shellClassName, onClose, children }: {
  label?: string;
  shellClassName: string;
  onClose: () => void;
  children: (close: () => void) => ReactNode;
}) {
  const [closing, setClosing] = useState(false);
  const closeTimer = useRef<number | null>(null);

  const requestClose = useCallback(() => {
    if (closing) return;
    setClosing(true);
    closeTimer.current = window.setTimeout(onClose, 250);
  }, [closing, onClose]);

  useEffect(() => {
    return () => {
      if (closeTimer.current !== null) window.clearTimeout(closeTimer.current);
    };
  }, []);

  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.key === "Escape") {
        e.preventDefault();
        requestClose();
      }
    }
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [requestClose]);

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-label={label}
      className={`preview-overlay ${closing ? "is-closing" : "is-open"} fixed inset-0 z-30 flex items-center justify-center bg-black/70 px-4 backdrop-blur-md`}
      onMouseDown={(e) => {
        if (e.target === e.currentTarget) requestClose();
      }}
    >
      <div className={`bezel-shell preview-shell ${closing ? "is-closing" : "is-open"} relative flex max-h-full flex-col overflow-hidden ${shellClassName}`}>
        {children(requestClose)}
      </div>
    </div>
  );
}
