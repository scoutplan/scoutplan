import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "toggle"];

  close() {
    this.toggleTarget.checked = false;
  }
}