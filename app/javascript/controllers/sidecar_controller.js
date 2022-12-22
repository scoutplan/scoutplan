import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "source" ];

  connect() {
    var elem = document.querySelector("#sidecar_toggle");
    var compStyles = window.getComputedStyle(elem);
    var compDisplay = compStyles.getPropertyValue("display");
    if(compDisplay == "none") { return; }
    
    window.scrollTo(0, elem.offsetTop - 70);
  }

  reveal(event) {
    window.scrollTo(0, 0);
    document.body.classList.add("sidecar-open");
  }
}