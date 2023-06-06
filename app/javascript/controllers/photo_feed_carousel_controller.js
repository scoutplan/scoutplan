import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "leftButton", "rightButton", "scrollable", "indicator" ];
  static values = {
    imageIndex: Number,
    imageCount: Number
  };

  connect() {
    console.log("PhotoFeedCarouselController#connect");
  }

  scrollLeft(event) {
    this.scrollableTarget.scrollLeft -= this.scrollableTarget.offsetWidth;
    event.preventDefault();
    this.imageIndexValue -= 1;
    this.setIndicator(this.imageIndexValue);
    this.setButtons(this.imageIndexValue, this.imageCountValue);
  }

  scrollRight(event) {
    console.log("scrollRight");
    this.scrollableTarget.scrollLeft += this.scrollableTarget.offsetWidth;
    this.leftButtonTarget.classList.remove("hidden");
    this.imageIndexValue += 1;
    event.preventDefault();
    this.setIndicator(this.imageIndexValue);
    this.setButtons(this.imageIndexValue, this.imageCountValue);
  }

  setIndicator(index) {
    var i = 0;
    this.indicatorTarget.querySelectorAll("svg").forEach(function(elem) {
      elem.classList.toggle("text-white/100", (i == index));
      elem.classList.toggle("text-white/50", (i != index));
      i += 1;
    });
  }

  setButtons(index, count) {
    this.leftButtonTarget.classList.toggle("hidden", (index == 0));
    this.rightButtonTarget.classList.toggle("hidden", (index == count - 1));
  }
}