import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "deleteform", "fileinput", "documentLibraryIds", "startsAtDate", "rsvpClosesAt" ];

  connect() {
    console.log("event organize controller connected");
  }

  drop(event) {
    event.preventDefault();
    console.log("drop");
  }

  dragover(event) {
    event.preventDefault();
    console.log("dragover");
  }

  dragenter(event) {
    event.preventDefault();
    console.log(event.target);
    event.target.classList.add("droptarget");
  }

  dragleave(event) {
    event.preventDefault();
    console.log("dragleave");
    event.target.classList.remove("droptarget");
  }
}