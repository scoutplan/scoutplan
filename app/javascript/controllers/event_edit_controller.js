import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
  }

  showLocation() {
    document.querySelector("#new_location_overlay").classList.remove("hidden");
    document.querySelector("#location_name").focus();
  }

  hideLocation(event) {
    document.querySelector("#new_location_overlay").classList.add("hidden");
    event.preventDefault();
  }

  hideLocationAndContinue(event) {
    document.querySelector("#new_location_overlay").classList.add("hidden");
  }
}