import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.querySelectorAll("input").forEach(function(elem) {
      elem.dataset.action = "dirt-detector#soil";
    });
  }
  
  soil(event) {
    console.log("I've been soiled");
    this.element.classList.add("is-dirty");
  }
}