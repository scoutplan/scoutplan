import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { returnUrl: String, elementIdValue: String };

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
    this.dispatch("close", { detail: { content: event } });
    const wrapper = this.element.closest(".modal-wrapper");
    const details = this.element.closest("details");
    
    if (this.hasElementIdValue) {
      elem = document.getElementById(this.elementIdValue);
      elem.remove();
    } else if (details) {
      details.removeAttribute("open");
    } else if (wrapper) {
      wrapper.remove();
    } else {
      this.element.closest("turbo-frame").innerHTML = "";
    }
    if (this.hasReturnUrlValue) {
      window.history.replaceState( {} , "", this.returnUrlValue );
    }
  }

  click(event) {
    const target = event.target.closest(".modal-dialog");
    if (!target) { this.close(event); }
  }
}