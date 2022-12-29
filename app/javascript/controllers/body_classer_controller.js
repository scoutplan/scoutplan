import { Controller } from "@hotwired/stimulus"

const ACTIVE_CLASS = "body-classer-active";
const SELECTOR = "[data-body-class]"

export default class extends Controller {
  connect() {
    document.querySelectorAll(SELECTOR).forEach(function(elem) {
      elem.dataset.action = "body-classer#change";
      if (elem.tagName == "INPUT") { this.toggle(elem); }
    }.bind(this));
    document.body.classList.add(ACTIVE_CLASS);
  }

  change(event) {
    this.toggle(event.target);
    event.preventDefault();
  }
  
  toggle(elem) {
    var className = elem.dataset.bodyClass;
    if (elem.tagName == "INPUT") {
      document.body.classList.toggle(className, elem.checked);
    } else {
      document.body.classList.toggle(className);
    }
  }
}