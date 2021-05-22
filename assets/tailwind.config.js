module.exports = {
  purge: [
    '../lib/**/*.ex',
    '../lib/**/*.leex',
    '../lib/**/*.eex',
    './js/**/*.js'
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    fontFamily: {
      'serif': ['roboto-slab']
    },
    extend: {
      colors: {
        orange: "#FF9000",
        white: "#F4EDE8",
        gray: "#999591",
        'gray-hard': "#666360",
        shape: "#3E3B47",
        'black-medium': "#28262E",
        background: "#312E38",
        inputs: "#232129"
      },
      backgroundImage: theme => ({
        'sign-up': "url('/images/sign_up_bg.png')",
      })
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
