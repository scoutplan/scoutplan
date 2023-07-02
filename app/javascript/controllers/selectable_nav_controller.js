import { Controller } from "@hotwired/stimulus"



export default class extends Controller {
  connect() {
    this.element.querySelectorAll("a").forEach(function(elem) {
      elem.dataset.action = "selectable-nav#change";
    });
  }

  change(event) {
    this.element.querySelectorAll("a").forEach(function(elem) {
      elem.classList.remove("active");
    });
    event.target.classList.add("active");
  }
}