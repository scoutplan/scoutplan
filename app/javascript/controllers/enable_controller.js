import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input" ];

  change(event) {
    console.log(event.target);
    this.inputTarget.disabled = !event.target.checked;
    if (event.target.checked) {
      this.inputTarget.focus();
    }
  }
}