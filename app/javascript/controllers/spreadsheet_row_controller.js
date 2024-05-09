import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

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
}