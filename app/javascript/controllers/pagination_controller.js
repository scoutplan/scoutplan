// inspired by https://www.rubycube.dev/blog/infinite-scroll-rails-stimulus

import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {
  static targets = ["nextPageLink"];

  initialize() {
    this.observeNextPageLink();
  }

  async observeNextPageLink() {
    if (!this.hasNextPageLinkTarget) return;

    console.log(this.nextPageLinkTarget);

    await nextIntersection(this.nextPageLinkTarget);
    this.getNextPage();

    await delay(500);
    this.observeNextPageLink();
  }

  async getNextPage() {
    const response = await get(this.nextPageLinkTarget.href);
    const html = await response.text;
    const doc = new DOMParser().parseFromString(html, "text/html");
    const nextPageHTML = doc.querySelector(`[data-controller~=${this.identifier}]`).innerHTML;
    this.nextPageLinkTarget.outerHTML = nextPageHTML;
  }
}

const delay = (ms) => {
  return new Promise(resolve => setTimeout(resolve, ms))
}

const nextIntersection = function(targetElement) {
  let options = { rootMargin: "100px", threshold: 1.0 };

  return new Promise(resolve => {
    new IntersectionObserver(([element]) => {
      if (!element.isIntersecting) {
        return;
      } else {
        resolve();
      }
    }, options).observe(targetElement);
  });
}
