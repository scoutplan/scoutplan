import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const selectedInput = this.element.querySelector("input:checked");
    const label = this.element.querySelector("label[for=" + selectedInput.id + "]");
    const position = label.dataset.position;
    this.element.classList.add("selected-" + position);
  }

  click(event) {
    this.clearClasses();
    const position = event.target.dataset.position;
    this.element.classList.add("selected-" + position);
  }

  clearClasses() {
    ["left", "center", "right"].forEach((position) => {
      this.element.classList.remove("selected-" + position);
    });
  }
}
