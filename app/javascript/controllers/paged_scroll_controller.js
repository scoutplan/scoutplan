import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "left", "right", "scrollable" ];

  scrollLeft(event) {
    this.scrollableTarget.scrollLeft -= this.scrollableTarget.offsetWidth * 0.8;
    // event.target.scroll({ left: -this.scrollableTarget.offsetWidth, behavior: 'smooth' });
    event.preventDefault();
  }

  scrollRight(event) {
    this.scrollableTarget.scrollLeft += this.scrollableTarget.offsetWidth * 0.8;
    // event.target.scroll({ left: this.scrollableTarget.offsetWidth, behavior: 'smooth' });
    event.preventDefault();
  }
}