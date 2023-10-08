import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "selectableListItem" ];
  selected = null;

  connect() {
    this.element.querySelector(".search-result.contactable")?.classList?.add("selected");
  }

  deselect() {
    this.element.querySelectorAll(".selected").forEach((element) => {
      element.classList.remove("selected");
    });
  }

  select(event) {
    if (!event.target.classList.contains("contactable")) { return; }
    this.deselect();
    event.target.classList.add("selected");
  }
}