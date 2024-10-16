// Stimulus controller for autocomplete

import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"
import { destroy } from "@rails/request.js"

export default class extends Controller {
  static targets = ["header"];
  static values = { unitId: Number };

  offsetLeft = 0;
  draggingElem = null;
  OFFSET_Y = 90;
  observer = null;

  connect() {
    this.establishObserver();
    this.establishKeydown();
  }

  async insertRow(event) {
    await post(`/u/${this.unitIdValue}/schedule/spreadsheet/rows?before=${event.params.before}`, { responseKind: "turbo-stream" });
  }

  dragstart(event) {
  }

  dragend(event) {
  }

  dragover(event) {
    event.preventDefault();
  }

  drop(event) {
  }
  
  selectCell(event) {
    // this.clearSelected();
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
    const shift = event.getModifierState("Shift");
    const rowElem = event.target.closest(".table-row");

    // this.element.querySelectorAll(".table-row").forEach((row) => {
    //   row.classList.toggle("selected", false);
    // });

    if (shift) {
      // multi-select

      const rows = Array.from(this.element.children);
      const selectedRows = this.element.querySelectorAll(".selected");
      const boundingRow1 = selectedRows[0];
      const boundingRow2 = event.target.closest(".table-row");

      var boundingRow1Index = rows.indexOf(boundingRow1);
      var boundingRow2Index = rows.indexOf(boundingRow2);

      if (boundingRow1Index > boundingRow2Index) {
        const temp = boundingRow1Index;
        boundingRow1Index = boundingRow2Index;
        boundingRow2Index = temp;
      }

      for (let i = boundingRow1Index; i <= boundingRow2Index; i++) {
        const row = rows[i];
        row.classList.toggle("selected", true);
      }

    } else {
      this.clearSelected();
      rowElem.classList.toggle("selected", true);
    }
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
    // this.clearSelected();
    this.draggingElem = event.target.closest(".table-row");
    this.draggingElem.style.position = "absolute";
    this.draggingElem.classList.toggle("selected", true);
    event.preventDefault();
    event.stopPropagation();
  }

  mouseup(event) {
    this.draggingElem = null;
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

  establishObserver() {
    this.observer = new MutationObserver((mutations) => {
      for (const mututation of mutations) {
        if (mututation.type === "childList") {
          this.renumberRows();
        }
      }
    });

    this.observer.observe(this.element, { childList: true });
  }

  establishKeydown() {
    document.addEventListener("keydown", (event) => {
      if (event.key == "Backspace") {
        this.deleteSelected();
      }
    });
  }

  async deleteSelected() {
    const selectedRows = document.querySelectorAll(".selected");
    selectedRows.forEach((row) => {
      destroy(`/u/${this.unitIdValue}/schedule/${row.dataset.eventId}?context=spreadsheet`, { responseKind: "turbo-stream" });
    });
  }

  renumberRows() {
    const rows = Array.from(this.element.children);
    rows.forEach((row, index) => {
      const numberCell = row.querySelector(".cell-row-number");
      if (numberCell == null) { return; }
      
      numberCell.innerText = index + 1;
    });
  }
}