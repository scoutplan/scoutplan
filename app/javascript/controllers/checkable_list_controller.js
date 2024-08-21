import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = [ "tag-field" ];

  // called when a list item is checked or unchecked. Emits an event that other controllers can listen for.
  change(event) {
    // this.dispatch("change", { detail: { value: event.target.dataset.value, checked: event.target.checked }, target: this.element });
    if (this.hasTagFieldOutlet) {
      this.tagFieldOutlet.change({ detail: { value: event.target.dataset.value, checked: event.target.checked }});
    }
  }

  // called to uncheck a list item
  uncheck({ detail: content }) {
    const checkbox = this.element.querySelector(`input[data-value="${content.value}"]`);
    if (checkbox) { checkbox.checked = false; }
  }
}