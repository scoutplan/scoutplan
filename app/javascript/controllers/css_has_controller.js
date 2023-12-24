import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { selector: String, className: String };

  connect(event) {
    this.setup();
  }

  perform() {
    const found = this.element.querySelectorAll(this.selectorValue);
    this.element.classList.toggle(this.classNameValue, found.length > 0);
  }

  setup() {
    this.element.querySelectorAll("input").forEach((input) => {
      input.addEventListener("change", (event) => {
        this.perform();
      });
    });
  }
}