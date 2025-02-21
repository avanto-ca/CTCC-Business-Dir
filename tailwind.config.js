/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        'ctcc': {
          DEFAULT: '#7A2B8F',
          light: '#9B4CB0',
          dark: '#5A1B6F'
        }
      },
      typography: {
        DEFAULT: {
          css: {
            maxWidth: 'none',
            color: '#4B5563',
            p: {
              marginTop: '1em',
              marginBottom: '1em',
            },
            'ul > li': {
              marginTop: '0.5em',
              marginBottom: '0.5em',
            },
            a: {
              color: '#7A2B8F',
              '&:hover': {
                color: '#5A1B6F'
              },
              textDecoration: 'none'
            },
            'a:hover': {
              cursor: 'pointer'
            },
            img: {
              marginTop: '2em',
              marginBottom: '2em',
            },
            '.container': {
              padding: '0 !important',
              maxWidth: 'none',
              backgroundColor: 'transparent !important',
              boxShadow: 'none !important'
            },
            p: {
              marginTop: '1em !important',
              marginBottom: '1em !important',
              fontSize: '16px !important',
              lineHeight: '1.6 !important',
              color: '#34495e !important'
            }
          },
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
};
