const { scale } = require('tailwindcss/defaultTheme')
const defaultTheme = require('tailwindcss/defaultTheme')
const colors = require('tailwindcss/colors')

module.exports = {
  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*'
  ],
  theme: {
    extend: {
      backdropBrightness: {
        500: '5'
      },
      backdropSaturate: {
        10: '.10'
      },
      dropShadow: {
        overhead: '0 0 0.5rem rgba(0, 0, 0, 0.2)',
      },
      boxShadow: {
        button: 'inset 0 2px 4px 0 #ffffff, inset 0 -2px 2px 0 #d6d3d1;',
        buttonactive: 'inset 0 2px 0px 0 #d6d3d1, inset 0 -2px 0px 0 #ffffff;',
        buttondark: 'inset 0 2px 0 0 #78716c, inset 0 -2px 0 0 rgb(0, 0, 0);',
        buttondarkactive: 'inset 0 3px 0 0 #0c0a09, inset 0 2px 6px 2px #78716c;',
        overhead: '0 0 0.5rem rgba(0, 0, 0, 0.1)',
      },
      fontFamily: {
        sans: ["Inter", ...defaultTheme.fontFamily.sans],
        serif: [...defaultTheme.fontFamily.serif],
      },
      fontSize: {
        '2xs': ['0.5rem', '1'],
        huge: ['5rem', '1'],

     
      },
      colors: {
        // https://uicolors.app/create
        brand: {
          50:  '#F9F7F6',
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
        },
        messages: colors.lime
      },
      listStyleType: {
        square: 'square',
      },
      maxWidth: {
        '1/2': '50%',
        '8xl': '96rem',
      },
      minWidth: {
        '96': '24rem',
      },
      animation: {
        'pop-open': 'pop-open 0.1s',
        'fade-out-after-load': 'fade-out-after-load 10s linear',
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
          '80%': {
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
    require('@tailwindcss/typography'),
  ]
}
