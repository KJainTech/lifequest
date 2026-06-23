import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        lq: {
          slate: {
            950: "#0f1419",
            900: "#151b23",
            800: "#1e2732",
            700: "#2a3544",
            600: "#3d4f63",
            500: "#64748b",
            400: "#94a3b8",
            300: "#cbd5e1",
            200: "#e2e8f0",
            100: "#f1f5f9",
            50: "#f8fafc",
          },
          emerald: {
            700: "#047857",
            600: "#059669",
            500: "#10b981",
            400: "#34d399",
            100: "#d1fae5",
            50: "#ecfdf5",
          },
        },
      },
      fontFamily: {
        sans: [
          "system-ui",
          "-apple-system",
          "BlinkMacSystemFont",
          "Segoe UI",
          "Roboto",
          "sans-serif",
        ],
      },
      boxShadow: {
        card: "0 1px 3px 0 rgb(15 20 25 / 0.06), 0 1px 2px -1px rgb(15 20 25 / 0.06)",
        elevated:
          "0 4px 6px -1px rgb(15 20 25 / 0.08), 0 2px 4px -2px rgb(15 20 25 / 0.06)",
      },
    },
  },
  plugins: [],
};

export default config;
