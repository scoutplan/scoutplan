import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "dropdown", "toggle", "menu" ];

  // connect() {
  //   document.addEventListener("click", function(e) {
  //     if (e.target == this.toggleTarget) {
  //       return;
  //     }

  //     // if the click is inside the fancy-select, ignore it...
  //     if (e.target == this.element) {
  //       return;
  //     }
  
  //     // ...otherwise, close up shop
  //     this.close();
  //   }.bind(this));
  // }    

  toggle(event) {
    this.element.classList.toggle("dropdown-active");
    if (this.hasMenuTarget) {
      this.menuTarget.classList.toggle("hidden");
    }
    event.preventDefault();
  }

  close() {
    this.element.classList.remove("dropdown-active");
    if (this.hasMenuTarget) {
      this.menuTarget.classList.add("hidden");
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }
}