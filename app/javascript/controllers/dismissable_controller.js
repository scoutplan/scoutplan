import { Controller } from "@hotwired/stimulus"

// Closes a <details> disclosure when the click lands outside it.
//
// The rail's popups are built two different ways: the location picker nests its
// popup inside the <details>, while the tags and organizers popups are separate
// elements revealed by a body:has(details[open]) CSS rule. Pass popupId for the
// second kind so clicks inside that popup don't count as "outside".
export default class extends Controller {
  static values = { popupId: String };

  connect() {
    this.onDocumentClick = this.onDocumentClick.bind(this);
    this.onKeydown = this.onKeydown.bind(this);
    document.addEventListener("click", this.onDocumentClick);
    document.addEventListener("keydown", this.onKeydown);
  }

  disconnect() {
    document.removeEventListener("click", this.onDocumentClick);
    document.removeEventListener("keydown", this.onKeydown);
  }

  onDocumentClick(event) {
    if (!this.element.open) { return; }
    if (this.element.contains(event.target)) { return; }
    if (this.popup?.contains(event.target)) { return; }

    this.close();
  }

  onKeydown(event) {
    if (event.key === "Escape" && this.element.open) { this.close(); }
  }

  close() {
    this.element.removeAttribute("open");
  }

  get popup() {
    return this.hasPopupIdValue ? document.getElementById(this.popupIdValue) : null;
  }
}
