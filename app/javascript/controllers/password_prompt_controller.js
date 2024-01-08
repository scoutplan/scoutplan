import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  dismiss(event) {
    this.element.classList.add("hidden");
    document.cookie = "password_prompt_dismissed=true;samesite=strict;path=/";
    event.preventDefault();
    event.stopPropagation();
  }
}