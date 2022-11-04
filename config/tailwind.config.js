const { scale } = require('tailwindcss/defaultTheme')
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*'
  ],
  theme: {
    extend: {
      fontFamily: {
//        sans: ['proxima-nova', ...defaultTheme.fontFamily.sans],
        sans: ["-apple-system", "BlinkMacSystemFont", "Segoe UI", "Roboto", "Helvetica", "Arial", "sans-serif", "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol"],
        serif: [...defaultTheme.fontFamily.serif],
      },
      colors: {
        brand: {
          100: '#F6F1E7',
          200: '#F4E1CC',
          300: '#EDAD81',
          400: '#EA7731',
          500: '#E66425',
          600: '#BC521E',
          700: '#913F17',
          800: '#4E210A',
          900: '#300F08'          
        },
        adult: {
          100: '',
          500: '',
          700: '',
        },
        youth: {
          100: '',
          500: '',
          700: '',
        }
      },
      maxWidth: {
        '1/2': '50%',
      },
      animation: {
        'pop-open': 'pop-open 0.1s',
        'fade-out-after-load': 'fade-out-after-load 3s linear 1',
      },
      keyframes: {
        'pop-open': {
          '0%': {
            transform: 'scale(0%)'
          },
          '90%': {
            transform: 'scale(110%)'
          },
          '100%': {
            transform: 'scale(100%)'
          }
        },
        'fade-out-after-load': {
          '0%': {
            opacity: '1'
          },
          '100%': {
            opacity: '0'
          }
        }
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/line-clamp'),
  ]
}
