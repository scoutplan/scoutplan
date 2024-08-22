import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = [ "tag-field" ];

  // called when a list item is checked or unchecked. Emits an event that other controllers can listen for.
  change(event) {
    const checkbox = event.currentTarget;

    if (this.hasTagFieldOutlet) {
      this.tagFieldOutlet.change({ detail: { value: checkbox.dataset.value, checked: checkbox.checked }});
    }
  }

  // called remotely to uncheck a list item
  uncheck({ detail: content }) {
    const checkbox = this.element.querySelector(`input[data-value="${content.value}"]`);
    if (checkbox) { checkbox.checked = false; }
  }
}