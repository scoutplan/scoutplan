import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "selectableList", "selectAllButton", "deselectAllButton", "deselectSomeButton" ];

  connect() {
    console.log("list-selection controller connected");
  }

  selectItem(event) {
    const selectedItems = Array.from(this.element.querySelectorAll(".document-item:checked"));
    this.element.classList.toggle("selections-present", selectedItems.length > 0);
  }
}