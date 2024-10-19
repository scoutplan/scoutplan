import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {
  static targets = [""]
  static values = { unitId: Number }

  multiSelect() {
    const selectedDocIds = Array.from(this.element.querySelectorAll(".multi-selector-checkbox:checked")).map(node => node.value);
    const url = `/u/${this.unitIdValue}/document_sets/new`;
    get(url, { query: { document_ids: selectedDocIds.join(",") }, responseKind: "turbo-stream" });      
  }

  checkable(node) {
    if (node.closest("li").classList.contains("hidden")) { return false; }

    return true;
  }

  selectAll() {
    this.element.querySelectorAll(".multi-selector-checkbox").forEach(node => node.checked = this.checkable(node));
    this.multiSelect();
  }
  
  deselectAll() {
    this.element.querySelectorAll(".multi-selector-checkbox").forEach(node => node.checked = false);
    this.multiSelect();
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