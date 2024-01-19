// Stimulus controller for autocomplete

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["header"];

  offsetLeft = 0;
  draggingElem = null;
  OFFSET_Y = 90;

  connect() {
    console.log("Spreadsheet controller connected")
  }
  
  selectCell(event) {
    this.clearSelected();
    const cellElem = event.target.closest(".table-cell");
    cellElem.classList.toggle("selected", true);
    const rowElem = cellElem.closest(".table-row")
    rowElem.classList.toggle("cell-selected", true);
    var index = 0;
    var child = cellElem;
    while( (child = child.previousSibling) != null ) {
      index++;
    }
    // const index = rowElem.children.indexOf(cellElem);
    this.headerTarget.children[index].classList.toggle("cell-selected", true);
  }

  selectRow(event) {
    this.clearSelected();
    const rowElem = event.target.closest(".table-row");
    rowElem.classList.toggle("selected", true);
  }

  clearSelected() {
    const elems = document.querySelectorAll(".selected");
    elems.forEach((row) => {
      row.classList.toggle("selected", false);
    });

    const cellElems = document.querySelectorAll(".cell-selected");
    cellElems.forEach((cell) => {
      cell.classList.toggle("cell-selected", false);
    });
  }

  mousedown(event) {
    this.clearSelected();
    this.draggingElem = event.target.closest(".table-row");
    this.draggingElem.style.position = "absolute";
    this.draggingElem.classList.toggle("selected", true);
    event.preventDefault();
    event.stopPropagation();
  }

  mouseup(event) {
    this.draggingElem = null;
    console.log("mouseup");
  }

  mousemove(event) {
    if (this.draggingElem == null) { return; }

    const underElem = document.elementFromPoint(event.clientX, event.clientY);
    const rowElem = underElem.closest(".table-row");
    if (rowElem == null) { return; }



    this.draggingElem.style.top = event.clientY - this.OFFSET_Y + "px";
    this.draggingElem.querySelector(".day-cell").innerText = event.clientY - this.OFFSET_Y;
    event.preventDefault();
    event.stopPropagation();
  }
}