import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input" ];

  change(event) {
    this.inputTarget.disabled = !event.target.checked;
    if (event.target.checked) {
      this.inputTarget.focus();
    }
  }
}