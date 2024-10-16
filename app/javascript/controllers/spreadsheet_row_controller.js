import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"
import { patch } from "@rails/request.js"
import { get } from "@rails/request.js"

export default class extends Controller {
  static targets = ["insertionCursor"];
  static values = { unitId: Number, newRow: Boolean };
  movedOut = false;

  showInsertionCursor(event) {
    if (this.newRowValue && !this.movedOut) { return; }

    if (this.inserting) { return; }
    this.insertionCursorTarget.classList.toggle("hidden", false);
  }

  hideInsertionCursor(event) {
    this.insertionCursorTarget.classList.toggle("hidden", true);
    this.movedOut = true;
  }

  async insertRow(event) {
    this.hideInsertionCursor();
    await post(`/u/${event.params.unit}/schedule/spreadsheet/rows?before=${event.params.before}`, { responseKind: "turbo-stream" });
  }

  navigateToEvent(event) {
    const row = event.originalTarget.closest(".table-row");
    const eventId = row.dataset.eventId;
    const url = `/u/${this.unitIdValue}/schedule/${eventId}`;
    window.location = url;
  }

  changeEventStatus(event) {
    var selectedRows = this.element.closest(".table").querySelectorAll(".selected");
    const checkbox = event.target;
    const checked = checkbox.checked;
    
    if (selectedRows.length == 0) { selectedRows = [checkbox.closest(".table-row")]; }

    selectedRows.forEach(row => {
      const selectedCheckbox = row.querySelector(".event-status-checkbox input[type='checkbox']");
      selectedCheckbox.checked = checked;
    });

    const eventIds = Array.from(selectedRows).map(row => row.dataset.eventId);
    const body = new FormData();
    body.append(`event[status]`, checkbox.checked ? "published" : "draft");
    body.append(`event_ids`, eventIds.join(","));

    const url = `/u/${this.unitIdValue}/schedule/batch_updates`;
    post(url, { body: body, responseKind: "turbo-stream" });
  }

  dragstart(event) {
    event.dataTransfer.dropEffect = "move";
    event.dataTransfer.setData("text/plain", event.currentTarget.dataset.eventId);
  }

  dragover(event) {
  }

  dragenter(event) {
    event.currentTarget.classList.toggle("dragover", true);
  }

  dragleave(event) {
    event.currentTarget.classList.toggle("dragover", false);
  }

  dragover(event) {
    event.preventDefault();
  }

  drop(event) {
    event.currentTarget.classList.toggle("dragover", false);

    const row = event.currentTarget.closest(".table-row");
    const beforeEventId = row.dataset.eventId;
    const movingEventId = event.dataTransfer.getData("text/plain");
  }
}