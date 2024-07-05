import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class extends Controller {
  static values = { unitId: Number };

  connect() {
    console.log("document-index controller connected");
  }

  openMultiSelect(event) {
    this.element.classList.toggle("multi-select-enabled", true);
  }

  closeMultiSelect(event) {
    this.element.classList.toggle("multi-select-enabled", false);
  }

  deleteSelected(event) {
    const body = new FormData();
    body.append(`document_ids`, this.selectedItemIds());
    const url = `/u/${this.unitIdValue}/library/batch_delete`;
    post(url, { body: body, responseKind: "turbo-stream" });    
  }

  selectedItems() {
    return Array.from(this.element.querySelectorAll(".document-item:checked"));
  }

  selectedItemIds() {
    return this.selectedItems().map(item => item.value).join(",");
  }
}
