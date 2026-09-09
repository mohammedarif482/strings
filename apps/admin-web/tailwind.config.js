/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        background: '#0B0B0E',
        surface: '#121015',
        brand: '#FF6B2C',
        brandLight: '#FF8A3D',
      },
    },
  },
  plugins: [],
}
