import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "attachmentList" ];
  static values = { seasonEndDate: String, unitId: String };

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
    for (let i = 0; i < this.fileInputTarget.files.length; i++) {
      let file = this.fileInputTarget.files[i];
      this.attachmentListTarget.insertAdjacentHTML("beforeend", `<li class="pending-attachment py-1 font-bold text-green-600">${file.name} (pending)</li>`);
    }
  }

  uploadFiles(event) {
    this.fileInputTarget.click();
    event.stopPropagation();
    event.preventDefault();
  }
}