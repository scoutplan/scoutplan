import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {
  static targets = [ "deleteform", "fileinput", "documentLibraryIds", "startsAtDate", "endsAtDate", "rsvpClosesAt", "repeatsUntilSelect" ];
  static values = { seasonEndDate: String, unitId: String };

  connect() {
    this.populateRepeatUntilSelectOptions();
  }

  addAttachmentToPendingList(filename) {
    var attachment_list = document.querySelector("#existing_attachments");
    attachment_list.insertAdjacentHTML("beforeend", `<li class="pending-attachment py-1 font-bold text-green-600">${filename} (pending)</li>`);
  }

  attachFromLibrary(event) {
    console.log("attach from library");
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

  updateLocation(event) {
    var location = event.target.value;
    if (location == "_new") { this.showLocation(); }
  }

  updateRsvpClosesAt() {
    var startsAt = this.startsAtDateTarget.value;
    var rsvpClosesAt = this.rsvpClosesAtTarget.value;
    if (rsvpClosesAt > startsAt) {
      this.rsvpClosesAtTarget.closest(".field-wrapper").classList.add("field_with_errors");
    } else {
      this.rsvpClosesAtTarget.closest(".field-wrapper").classList.remove("field_with_errors");
    }
  }

  updateStartsAt() {
    const startsAt = this.startsAtDateTarget.value;
    const endsAt = this.endsAtDateTarget.value;
    const rsvpClosesAt = this.rsvpClosesAtTarget.value;

    if (startsAt < rsvpClosesAt) { this.rsvpClosesAtTarget.value = startsAt; }
    if (startsAt > endsAt) { this.endsAtDateTarget.value = startsAt; }
    this.populateRepeatUntilSelectOptions();
  }

  async populateRepeatUntilSelectOptions() {
    const startsAt = this.startsAtDateTarget.value;
    const unitId = this.unitIdValue;
    const query = new URLSearchParams({ "a": "b", "starts_at": startsAt });
    await get(`/u/${unitId}/events/repeat_options/${startsAt}`, { query: query, responseKind: "turbo-stream" });     
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

  uploadFiles(event) {
    console.log("upload files");
    this.fileinputTarget.click();
    event.stopPropagation();
    event.preventDefault();
  }

  somethingElse() {
    console.log("something else");
  }

  keypress(event) {
    if (event.key === "Enter") {
      event.preventDefault();
      return false;
    }
  }
}