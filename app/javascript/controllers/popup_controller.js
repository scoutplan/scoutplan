import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.addEventListener("keydown", (event) => {
      if (event.key === "Escape") { this.close(event); }
    });
  }

  disconnect() {
    document.removeEventListener("keydown", (event) => {
      if (event.key === "Escape") { this.close(event); }
    });
  }

  close(event) {
    this.element.closest("details").removeAttribute("open");
    event.preventDefault();
    event.stopPropagation();
  }

  click(event) {
    const target = event.target.closest(".modal-dialog");
    if (!target) { this.close(event); }
  }
}