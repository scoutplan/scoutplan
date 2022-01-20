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
        sans: ['proxima-nova', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        scoutplan: {
          100: '#F6F1E7',
          200: '#F4E1CC',
          300: '#EDAD81',
          400: '#EA7731',
          500: '#E66425',
          600: '#BC521E',
          700: '#913F17',
          800: '#4E210A',
          900: '#300F08'
        }
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
}
