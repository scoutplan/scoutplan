import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { returnUrl: String, elementId: String };

  connect() {
    // bind once and keep the reference: addEventListener and removeEventListener
    // must be handed the *same* function object or the listener is never removed
    this.onKeydown = this.onKeydown.bind(this);
    document.addEventListener("keydown", this.onKeydown);
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown);
  }

  onKeydown(event) {
    if (event.key === "Escape") { this.close(event); }
  }

  close(event) {
    this.dispatch("close", { detail: { content: event } });

    const wrapper = this.element.closest(".modal-wrapper");
    const details = this.element.closest("details");
    const frame = this.element.closest("turbo-frame");

    if (this.hasElementIdValue) {
      document.getElementById(this.elementIdValue)?.remove();
    } else if (details) {
      details.removeAttribute("open");
    } else if (wrapper) {
      wrapper.remove();
    } else if (frame) {
      frame.innerHTML = "";
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
