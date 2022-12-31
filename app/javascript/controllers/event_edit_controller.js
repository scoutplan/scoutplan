import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
<<<<<<< HEAD
  static targets = [ "deleteform", "fileinput", "documentLibraryIds" ];

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
=======
  static targets = [ "deleteform", "fileinput" ];

  attachFromLibrary(event) {
    document.querySelector("#document_library_overlay").classList.add("hidden");
    var attachmentId = event.target.dataset.attachmentId;
    console.log(attachmentId);
>>>>>>> main
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
<<<<<<< HEAD
    this.clearPendingAttachments();
=======
    console.log(this.fileinputTarget.files.length);

>>>>>>> main

    var attachment_list = document.querySelector("#existing_attachments");
    for (let i = 0; i < this.fileinputTarget.files.length; i++) {
      let file = this.fileinputTarget.files[i];
<<<<<<< HEAD
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
=======
      attachment_list.insertAdjacentHTML("beforeend", `<li class="py-1 font-bold text-green-600">${file.name} (pending)</li>`);
    }
  }
>>>>>>> main
}