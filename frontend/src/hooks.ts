import { useEffect } from "react";

export function useRevealRoot(dep: unknown) {
  useEffect(() => {
    const els = Array.from(document.querySelectorAll(".reveal, .reveal-fade"));
    const io = new IntersectionObserver(
      (entries) => {
        for (const e of entries) {
          if (e.isIntersecting) {
            e.target.classList.add("is-visible");
            io.unobserve(e.target);
          }
        }
      },
      { threshold: 0.08 }
    );
    els.forEach((el) => io.observe(el));
    const fallback = setTimeout(() => {
      els.forEach((el) => el.classList.add("is-visible"));
    }, 1200);
    return () => {
      clearTimeout(fallback);
      io.disconnect();
    };
  }, [dep]);
}
