import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  observers = [];

  connect() {
    document.querySelectorAll("[data-label-update-source]").forEach((label) => {
      const source = document.querySelector(label.dataset.labelUpdateSource);
      if (source) {
        source.addEventListener("input", () => {
          label.textContent = source.value;
        });
        // this.observers.push(new MutationObserver(() => {
        //   label.textContent = source.value;
        // }).observe(source, { characterData: true, subtree: true }));
      }
    });
  }
}