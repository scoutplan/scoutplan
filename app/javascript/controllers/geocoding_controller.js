import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "query" ];
  connect() {
    this.element.textContent = "Hello World!"
  }
}
