import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  markForDestruction(event) {
    const wrapper = this.element;
    const input = wrapper.querySelector(".destroy-field");

    if (input) {
      input.value = 1;
      wrapper.style.display = "none";
    } else {
      wrapper.remove();
    }
  }
}
