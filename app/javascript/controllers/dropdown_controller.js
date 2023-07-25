import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "dropdown", "toggle" ];

  connect() {
    console.log("Hello, Stimulus!", this.element);
  }

  toggle(event) {
    console.log(this.element);
    this.element.classList.toggle("dropdown-active");
    event.preventDefault();
  }

  close() {
    this.element.classList.remove("dropdown-active");
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }
}