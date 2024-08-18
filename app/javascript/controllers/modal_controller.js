import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { returnUrl: String }

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
    this.element.closest("turbo-frame").innerHTML = "";
    // window.location = this.returnUrlValue;
    window.history.replaceState( {} , "", this.returnUrlValue );
  }

  click(event) {
    const target = event.target.closest(".modal-dialog");
    if (!target) { this.close(event); }
  }
}