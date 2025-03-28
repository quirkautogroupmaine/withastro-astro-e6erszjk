/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx,astro}'],
  theme: {
    extend: {
      colors: {
        primary: '#102654',
        secondary: '#3b71f7',
        cta: '#cc3233',
        tertiary: '#000000',
        'primary-dark': '#0a1a3d',
        'secondary-light': '#6490ff',
        dark: {
          50: '#f8fafc',
          100: '#f1f5f9',
          200: '#e2e8f0',
          300: '#cbd5e1',
          400: '#94a3b8',
          500: '#64748b',
          600: '#1e293b',
          700: '#1a1f2d',
          800: '#0f172a',
          900: '#0d1424',
          950: '#020617',
        },
      },
      fontFamily: {
        sans: ['Roboto Flex', 'system-ui', 'sans-serif'],
      },
      aspectRatio: {
        '16/9': '16 / 9', // ✅ Ensures proper video aspect ratio
        '4/3': '4 / 3',
        '1/1': '1 / 1',
      },
      spacing: {
        'video-max': '960px', // ✅ Limits video width for large screens
      },
      typography: {
        DEFAULT: {
          css: {
            color: '#1a202c',
            backgroundColor: 'white',

            /* ✅ Headings */
            h1: { color: '#102654', fontWeight: '700', fontSize: '2rem', marginBottom: '0.75rem' },
            h2: { color: '#102654', fontWeight: '600', fontSize: '1.75rem', marginBottom: '0.65rem' },
            h3: { color: '#102654', fontWeight: '600', fontSize: '1.5rem', marginBottom: '0.55rem' },
            h4: { color: '#102654', fontWeight: '500', fontSize: '1.25rem', marginBottom: '0.45rem' },

            /* ✅ Strong (Bold) Text Fix */
            strong: { color: '#1a202c', fontWeight: '700' },

            /* ✅ Paragraphs & Links */
            p: { marginBottom: '1rem', lineHeight: '1.6' },
            a: { 
              color: '#3b71f7', 
              textDecoration: 'underline', 
              fontWeight: '500',
              '&:hover': { color: '#6490ff' }
            },

            /* ✅ Lists - Ensures Bullet Visibility */
            ul: { listStyleType: 'disc', paddingLeft: '1.5rem', marginTop: '0.5rem', marginBottom: '0.5rem' },
            ol: { listStyleType: 'decimal', paddingLeft: '1.5rem', marginTop: '0.5rem', marginBottom: '0.5rem' },
            li: { marginBottom: '0.25rem' },

            /* ✅ Modern Blockquote */
            blockquote: {
              position: 'relative',
              padding: '1.5rem 2rem',
              fontStyle: 'italic',
              fontSize: '1.25rem',
              fontWeight: '500',
              color: '#333',
              backgroundColor: '#f8f9fa', /* ✅ Light Gray Background */
              borderLeft: '5px solid #3b71f7', /* ✅ Blue accent border */
              borderRadius: '0.5rem', /* ✅ Soft rounded corners */
              margin: '1.5rem 0',
              boxShadow: '0 4px 8px rgba(0, 0, 0, 0.05)', /* ✅ Subtle shadow */
              textAlign: 'center',
            },

            'blockquote::before, blockquote::after': {
              content: '"“"',
              fontSize: '3rem',
              color: '#64748b', /* ✅ Dark gray color */
              fontWeight: '700',
              position: 'absolute',
            },

            'blockquote::before': {
              top: '0px',
              left: '-15px',
            },

            'blockquote::after': {
              bottom: '-5px',
              right: '-15px',
              content: '"”"',
            },

            /* ✅ Code Blocks */
            pre: {
              backgroundColor: '#1e293b',
              color: '#f8fafc',
              padding: '0.5rem',
              borderRadius: '0.25rem',
              overflowX: 'auto',
            },
            'pre code': { backgroundColor: 'transparent', color: 'inherit' },
            code: {
              backgroundColor: '#eeeeee',
              padding: '0.15rem 0.3rem',
              borderRadius: '0.25rem',
              fontSize: '0.9em',
            },

            /* ✅ Horizontal Rules */
            hr: { 
              borderTop: '3px solid #64748b', /* ✅ Dark Gray */
              marginTop: '1.5rem', 
              marginBottom: '1.5rem',
              opacity: '0.8', /* ✅ Subtle transparency */
              borderRadius: '2px', /* ✅ Smooth edges */
              boxShadow: '0px 2px 4px rgba(0, 0, 0, 0.15)' /* ✅ Soft shadow */
            },

            /* ✅ Table Styling */
            table: { borderCollapse: 'separate', borderSpacing: '0', width: '100%' },
            thead: { backgroundColor: '#102654' },
            'thead th': {
              backgroundColor: '#102654 !important', /* ✅ Ensures primary background */
              color: '#ffffff !important', /* ✅ Forces white text */
              borderBottom: '2px solid #e5e7eb',
              padding: '0.2rem',
              textAlign: 'left',
              fontWeight: '600',
            },
            'tbody td': {
              border: '1px solid #e5e7eb',
              backgroundColor: '#eeeeee',
              padding: '0.2rem',
              textAlign: 'left',
            },
            'tbody tr:nth-child(even) td': { backgroundColor: '#f9fafb' },
            'tbody tr:hover td': { backgroundColor: '#e5e7eb' },

            /* ✅ Form Elements */
            input: {
              border: '1px solid #e5e7eb',
              borderRadius: '0.25rem',
              padding: '0.5rem',
              outline: 'none',
              '&:focus': { borderColor: '#3b71f7', boxShadow: '0 0 0 3px rgba(59, 113, 247, 0.25)' },
            },

            button: {
              backgroundColor: '#3b71f7',
              color: '#ffffff',
              padding: '0.5rem 1rem',
              borderRadius: '0.25rem',
              fontWeight: '500',
              '&:hover': { backgroundColor: '#6490ff' },
            },
          },
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/aspect-ratio'), // ✅ Ensures YouTube embeds stay responsive
  ],
};
