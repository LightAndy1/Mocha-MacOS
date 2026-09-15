/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        mocha: {
          bg: "#0f0e0d",
          surface: "#141210",
          elevated: "#1d1916",
          overlay: "#171310",
          border: "#24201c",
          bordervisible: "#322c27",
          primary: "#ede5da",
          secondary: "#b8aea1",
          muted: "#82776c",
          dim: "#544c44",
          gold: "#c9a86c",
          goldbright: "#e8c98a",
        },
      },
      fontFamily: {
        ui: ["Outfit", "Plus Jakarta Sans", "system-ui", "sans-serif"],
        mono: ["JetBrains Mono", "ui-monospace", "monospace"],
        serif: ["Lora", "Georgia", "serif"],
      },
    },
  },
  plugins: [],
};
