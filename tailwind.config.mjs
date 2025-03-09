/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      colors: {
        primary: '#102654',
        secondary: '#3b71f7',
        cta: '#cc3233',
        tertiary: '#000000',
        'primary-dark': '#0a1a3d',
        'secondary-light': '#6490ff',
      },
      fontFamily: {
        sans: ['Roboto Flex Variable', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}