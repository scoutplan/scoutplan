import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "toggle"];

  connect() {
    console.log("Hello, Stimulus!")
  }

  close() {
    this.toggleTarget.checked = false;
  }

  disconnect() {
    // this.element
  }

  // initialize() {}
  // connect() {}
  // disconnect() {}
  // start() {}
  // stop() {}
  // pause() {}
  // resume() {}
  // destroy() {}
  // click(event) {}
  // keydown(event) {}
  // keyup(event) {}
  // mousedown(event) {}
  // mouseup(event) {}
  // mousemove(event) {}
  // mouseover(event) {}
  // mouseout(event) {}
  // mouseenter(event) {}
  // mouseleave(event) {}
  // touchstart(event) {}
  // touchmove(event) {}
  // touchend(event) {}
  // touchcancel(event) {}
  // selectstart(event) {}
  // select(event) {}
  // selectend(event) {}
  // dragstart(event) {}
  // drag(event) {}
  // dragend(event) {}
  // dragenter(event) {}
  // dragover(event) {}
  // dragleave(event) {}
  // drop(event) {}
  // focusin(event) {}
  // focusout(event) {}
  // focus(event) {}
  // blur(event) {}
}