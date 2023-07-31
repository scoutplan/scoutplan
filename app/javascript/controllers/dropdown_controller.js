import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "dropdown", "toggle" ];

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
    event.preventDefault();
  }

  close() {
    this.element.classList.remove("dropdown-active");
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }
}