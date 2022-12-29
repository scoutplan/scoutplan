import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "deleteform", "fileinput" ];

  attachFromLibrary(event) {
    document.querySelector("#document_library_overlay").classList.add("hidden");
    var attachmentId = event.target.dataset.attachmentId;
    console.log(attachmentId);
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
    console.log(this.fileinputTarget.files.length);


    var attachment_list = document.querySelector("#existing_attachments");
    for (let i = 0; i < this.fileinputTarget.files.length; i++) {
      let file = this.fileinputTarget.files[i];
      attachment_list.insertAdjacentHTML("beforeend", `<li class="py-1 font-bold text-green-600">${file.name} (pending)</li>`);
    }
  }
}