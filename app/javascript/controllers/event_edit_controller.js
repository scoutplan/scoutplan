import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "deleteform", "fileinput", "documentLibraryIds", "startsAtDate", "rsvpClosesAt" ];

  addAttachmentToPendingList(filename) {
    var attachment_list = document.querySelector("#existing_attachments");
    attachment_list.insertAdjacentHTML("beforeend", `<li class="pending-attachment py-1 font-bold text-green-600">${filename} (pending)</li>`);
  }

  attachFromLibrary(event) {
    var link = event.target.closest("a")
    var attachmentId = link.dataset.attachmentId;
    var filename = link.dataset.filename;
    this.documentLibraryIdsTarget.value += attachmentId + ",";
    this.addAttachmentToPendingList(filename);
    document.querySelector("#document_library_overlay").classList.add("hidden");
    event.preventDefault();
  }

  browseDocumentLibrary(event) {
    document.querySelector("#document_library_overlay").classList.remove("hidden");
    event.preventDefault();
  }

  delete(event) {
    this.deleteformTarget.submit();
    console.log("delete this!");
    event.preventDefault();
  }

  hideDocumentLibrary() {
    document.querySelector("#document_library_overlay").classList.add("hidden");
  }    

  showLocation() {
    document.querySelector("#new_location_overlay").classList.remove("hidden");
    document.querySelector("#location_name").focus();
  }

  updateRsvpClosesAt() {
    var startsAt = this.startsAtDateTarget.value;
    var rsvpClosesAt = this.rsvpClosesAtTarget.value;
    if (rsvpClosesAt > startsAt) {
      this.rsvpClosesAtTarget.closest(".field-wrapper").classList.add("field_with_errors");
    }
  }

  updateStartsAt() {
    var startsAt = this.startsAtDateTarget.value;
    var rsvpClosesAt = this.rsvpClosesAtTarget.value;
    if (startsAt < rsvpClosesAt) {
      this.rsvpClosesAtTarget.value = startsAt;
    }
  }

  hideDocumentLibrary(event) {
    document.querySelector("#document_library_overlay").classList.add("hidden");
    event.preventDefault();
  }

  hideLocation(event) {
    document.querySelector("#new_location_overlay").classList.add("hidden");
    event.preventDefault();
  }

  hideLocationAndContinue(event) {
    document.querySelector("#new_location_overlay").classList.add("hidden");
  }

  showAttachments(event) {
    this.clearPendingAttachments();

    var attachment_list = document.querySelector("#existing_attachments");
    for (let i = 0; i < this.fileinputTarget.files.length; i++) {
      let file = this.fileinputTarget.files[i];
      attachment_list.insertAdjacentHTML("beforeend", `<li class="pending-attachment py-1 font-bold text-green-600">${file.name} (pending)</li>`);
    }
  }

  clearPendingAttachments() {
    var attachment_list = document.querySelector("#existing_attachments");
    var pending_attachments = document.querySelectorAll(".pending-attachment");
    pending_attachments.forEach(function(attachment) {
      attachment_list.removeChild(attachment);
    });
  }
}