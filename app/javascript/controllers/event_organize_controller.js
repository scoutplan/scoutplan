import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "deleteform", "fileinput", "documentLibraryIds", "startsAtDate", "rsvpClosesAt" ];

  connect() {

  }

  drop(event) {
    event.preventDefault();
  }

  dragover(event) {
    event.preventDefault();
  }

  dragenter(event) {
    event.preventDefault();
    event.target.classList.add("droptarget");
  }

  dragleave(event) {
    event.preventDefault();
    event.target.classList.remove("droptarget");
  }
}