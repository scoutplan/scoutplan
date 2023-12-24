import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  observer = null;

  initialize() {
    this.establishObserver();  
  }

  sortChildren() {
    const children = Array.from(this.element.children);
    const sorted = children.sort(compareElements);
    sorted.forEach(this.append);
  }

  append = child => this.element.append(child);

  establishObserver() {
    this.observer = new MutationObserver((mutations) => {
      if (mutations[0].addedNodes.length == 0) { return; }

      this.sortChildren();
    });
    this.observer.observe(this.element, { childList: true });
  }
}

function compareElements(a, b) {
  const aText = a.dataset.sortText || a.textContent.trim();
  const bText = b.dataset.sortText || b.textContent.trim();
  return aText.localeCompare(bText);
}