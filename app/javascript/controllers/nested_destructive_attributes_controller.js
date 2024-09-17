import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  markForDestruction(event) {
    const wrapper = this.element;
    const input = wrapper.querySelector(".destroy-field");
    input.value = 1;
    wrapper.style.display = "none";
  }
}
