import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [""]

  connect() {
    this.resizeObserver = new ResizeObserver(() => { this.resize() });
    this.resizeObserver.observe(this.element);
    this.canvas = document.createElement("canvas");
    this.resize();
  }

  disconnect() {
    this.resizeObserver.disconnect(this.element)
  }

  resize() {
    this.element.querySelectorAll('.truncation-container').forEach((el) => {
      const width = el.offsetWidth - 70;
      const truncatable = el.querySelector('.truncatable');
      const originalText = truncatable.dataset.originalText;
      console.log(originalText);
      var candidateText = originalText;
      var textWidth = this.getTextWidth(candidateText);
      var leftPortion = '';
      var rightPortion = '';
      var index = 0;
      console.log(textWidth, width);
      while (textWidth > width) {
        if (leftPortion == '') {
          const breakIndex = Math.floor(originalText.length / 2);
          leftPortion = originalText.slice(0, breakIndex);
          rightPortion = originalText.slice(breakIndex);
        }
        if (leftPortion.length > rightPortion.length) {
          leftPortion = leftPortion.slice(0, -1);
        } else {
          rightPortion = rightPortion.slice(1);
        }
        candidateText = leftPortion + '...' + rightPortion;
        textWidth = this.getTextWidth(candidateText);
        index++;
        if (index > originalText.length) { break; }
      }
      truncatable.textContent = candidateText;
    });
  }

  getTextWidth(text) {
    const font = "16px Inter";
    const context = this.canvas.getContext("2d");
    context.font = font;
    const metrics = context.measureText(text);
    return metrics.width;
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