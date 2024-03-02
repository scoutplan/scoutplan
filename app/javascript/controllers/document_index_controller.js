import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("document-index controller connected");
  }

  openMultiSelect(event) {
    this.element.classList.toggle("multi-select-enabled", true);
  }

  closeMultiSelect(event) {
    this.element.classList.toggle("multi-select-enabled", false);
  }  
}
