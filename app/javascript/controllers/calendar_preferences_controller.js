import { Controller } from "@hotwired/stimulus"

export default class extends Controller {  
  changeCategory(event) {
    document.querySelectorAll(".panel").forEach((panel) => {
      panel.classList.add("hidden");
    });

    document.querySelector(`#event_category_${event.target.value}_preferences`).classList.remove("hidden");
  }
}