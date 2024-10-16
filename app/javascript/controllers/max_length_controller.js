import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [""]
  static values = { maxLength: Number,
                    statusElement: String
                  }

  connect() {
  }

  disconnect() {
    // this.element
  }

  validate() {
    const remaining = this.maxLengthValue - this.element.value.length;
    if (remaining < 1) {
      this.element.value = this.element.value.substring(0, this.maxLengthValue);
    }
    const statusElement = document.querySelector(this.statusElementValue);
    if (statusElement) {
      statusElement.innerHTML = `${remaining} remaining`;
    }
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