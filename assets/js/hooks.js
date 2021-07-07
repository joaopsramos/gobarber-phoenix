let Hooks = {}

Hooks.Flash = {
  mounted() {
    this.el.addEventListener('transitioncancel', (e) => {
      e.stopPropagation();
      const result = /flash-([\w]*)/.exec(e.target.id);
      if (result) {
        const [_, key] = result
        this.pushEvent("lv:clear-flash", {key: key})
      }
    })
  }
}

export default Hooks
