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
          100: '#E6BE9C',
          200: '#E5AC7E',
          300: '#E69661',
          400: '#E68143',
          500: '#E66425',
          600: '#BC521E',
          700: '#913F17',
          800: '#5F220C',
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
