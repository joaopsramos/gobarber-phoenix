module.exports = {
  purge: {
    content: [
      '../lib/**/*.ex',
      '../lib/**/*.leex',
      '../lib/**/*.eex',
      './js/**/*.js'
    ],
    options: {
      safelist: [
        "flash-success",
        "flash-error",
        "flash-info"
      ]
    }
  },
  darkMode: false, // or 'media' or 'class'
  theme: {
    fontFamily: {
      'serif': ['Roboto Slab', 'serif']
    },
    extend: {
      colors: {
        orange: "#FF9000",
        white: "#F4EDE8",
        gray: "#999591",
        red: "#c53030",
        'gray-hard': "#666360",
        shape: "#3E3B47",
        'black-medium': "#28262E",
        background: "#312E38",
        inputs: "#232129",
        "toast-color-info": "#3172b7",
        "toast-back-info": "#e8f8ff",
        "toast-color-success": "#2e656a",
        "toast-back-success": "#e6fffa",
        "toast-color-error": "#ff5959",
        "toast-back-error": "#fddede",
      },
      backgroundImage: theme => ({
        'sign-up': "url('/images/sign_up_bg.png')",
        'sign-in': "url('/images/sign_in_bg.png')",
      })
    },
  },
  variants: {
    extend: {
      padding: ['last']
    },
  },
  plugins: [],
}
