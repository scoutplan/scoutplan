import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  keyDownListener = null;
  clickListener = null;
  scrim = null;

  connect() {
    this.scrim = document.createElement("div");
    this.scrim.classList.add("scrim");
    this.element.parentElement.insertBefore(this.scrim, this.element);
    this.scrim.classList.add("inset-0", "fixed", "bg-transparent", "z-0");

    this.keyDownListener = document.addEventListener("keydown", (event) => {
      if (event.key === "Escape") { this.close(event); }
    });

    this.scrim.addEventListener("click", (event) => {
      this.close(event);
    });

    this.clickListener = this.element.addEventListener("click", (event) => {
      event.stopPropagation();
      this.close();
    });
  }

  close() {
    if (this.element.closest("details")) {
      this.element.closest("details").open = false;
    } else {
      this.element.classList.toggle("hidden", true);
    }
  }
}