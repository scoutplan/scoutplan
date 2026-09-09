import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "field" ];

  change(event) {
    this.inputTarget.disabled = !event.target.checked;
    if (event.target.checked) {
      this.inputTarget.focus();
    }
  }

  // Show/hide variant. Unlike change(), this clears the value when switched
  // off: a disabled field submits nothing, so the old value would survive and
  // a hidden minimum would still be enforced.
  toggle(event) {
    const on = event.target.checked;
    const wrapper = this.hasFieldTarget ? this.fieldTarget : this.inputTarget;

    wrapper.classList.toggle("hidden", !on);

    if (on) {
      this.inputTarget.focus();
    } else {
      this.inputTarget.value = "";
    }
  }
}