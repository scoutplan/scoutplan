import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  draggedElem = null;
  
  dragover(event) {
    event.preventDefault();
    const columnElem = event.target.closest(".member-column");
    if (columnElem == this.draggedElem.closest(".member-column")) {
      event.dataTransfer.dropEffect = "none";
      return;
    }

    event.dataTransfer.dropEffect = "move";
    columnElem?.classList?.toggle("droptarget", true);  
  }

  drag(event) {
    this.draggedElem = event.target;
    // event.preventDefault();
    // const columnElem = event.target.closest(".member-column");
    // columnElem?.classList?.toggle("droptarget", true);    
  }

  dragenter(event) {
    // event.preventDefault();
    // const columnElem = event.target.closest(".member-column");
    // columnElem?.classList?.toggle("droptarget", true);
  }

  dragleave(event) {
    event.preventDefault();
    const columnElem = event.target.closest(".member-column");
    columnElem?.classList?.toggle("droptarget", false);
  }

  dragstart(event) {
    console.log("dragstart" + event.target.id);
    event.dataTransfer.dropEffect = "move";
  }

  drop(event) {
    console.log(event.target);
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