import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "source" ];
  static values = {
    text: String 
  };

  copy(event) {
    const value = this.textValue || event.target.innerText;
    navigator.clipboard.writeText(value);
    event.preventDefault();
  }
}
