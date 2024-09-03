import { Controller } from "@hotwired/stimulus"
import { get, post } from "@rails/request.js"
import { computePosition } from "https://cdn.jsdelivr.net/npm/@floating-ui/dom@1.6.10/+esm"

export default class extends Controller {
  static targets = [ "deleteform", "fileinput", "privatefileinput", "documentLibraryIds", "startsAtDate", "endsAtDate", "rsvpClosesAt", "repeatsUntilSelect",
      "submit", "categorySelect", "title", "newTagPrompt", "newTagName", "tagNotFoundPrompt", "tagListWrapper", "removeCoverPhotoField", "coverPhotoThumbnail",
      "coverPhotoFile", "coverPhotoThumbnailImage",
      "addressBook", "locationType", "eventLocationDetails"
   ];
  static values = { seasonEndDate: String, unitId: String };

  connect() {
    this.populateRepeatUntilSelectOptions();

    const tagsButton = document.querySelector("details#tags");
    const tagsPopup = document.querySelector("#tags_popup");

    computePosition(tagsButton, tagsPopup, { placement: "bottom-start" }).then(({x, y}) => {
      tagsPopup.style.left = `${x}px`;
      tagsPopup.style.top = `${y}px`;
    });

    const organizersButton = document.querySelector("details#organizers");
    const organizersPopup = document.querySelector("#organizers_popup");

    computePosition(organizersButton, organizersPopup, { placement: "bottom-start" }).then(({x, y}) => {
      organizersPopup.style.left = `${x}px`;
      organizersPopup.style.top = `${y}px`;
    });

    this.titleTarget.focus();
  }

  resetTagList() {
    this.tagSearchTarget.value = "";
    this.newTagPromptTarget.classList.add("hidden");   
    var tagList = document.querySelector("#tag_list");
    var tags = tagList.querySelectorAll("li");     
    tags.forEach(function(tag) {
      tag.classList.remove("hidden");
    });
  }

  hideTagList() {
    this.tagListWrapperTarget.removeAttribute("open");
  }

  validate(event) {
    var valid = true;
    valid = valid && this.categorySelectTarget.value != "";
    valid = valid && this.titleTarget.value != "";
    this.submitTarget.disabled = !valid;
  }

  removeCoverPhoto() {
    this.removeCoverPhotoFieldTarget.value = "1";
    this.coverPhotoThumbnailTarget.classList.add("hidden");
  }

  coverPhotoSelected(event) {
    const fileInput = this.coverPhotoFileTarget;
    const file = fileInput.files[0];
    const wrapper = this.coverPhotoThumbnailTarget;
    const image = document.createElement("img");

    image.src = URL.createObjectURL(file);

    wrapper.appendChild(image);
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
    // const query = new URLSearchParams({ "a": "b", "starts_at": startsAt });
    await get(`/u/${unitId}/schedule/repeat_options/${startsAt}`, { responseKind: "turbo-stream" });
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

  // showAttachments(event) {
  //   this.clearPendingAttachments();

  //   var attachment_list = document.querySelector("#existing_attachments");
  //   for (let i = 0; i < this.fileinputTarget.files.length; i++) {
  //     let file = this.fileinputTarget.files[i];
  //     attachment_list.insertAdjacentHTML("beforeend", `<li class="pending-attachment py-1 font-bold text-green-600">${file.name} (pending)</li>`);
  //   }
  // }

  showPrivateAttachments(event) {
    this.clearPendingPrivateAttachments();

    var attachment_list = document.querySelector("#existing_private_attachments");
    for (let i = 0; i < this.fileinputTarget.files.length; i++) {
      let file = this.privatefileinputTarget.files[i];
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

  clearPendingPrivateAttachments() {
    var attachment_list = document.querySelector("#existing_private_attachments");
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

  uploadPrivateFiles(event) {
    console.log("upload files");
    this.privatefileinputTarget.click();
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

  async updateCategory(event) {
    let category = event.target.value;
    if (category != "_new") { return; }

    let url = `/u/${this.unitIdValue}/event_categories/new`;
    await get(url, { responseKind: "turbo-stream" });

    let nameField = document.querySelector("#event_category_name");
    console.log(nameField);
    nameField.focus();
  }

  async setLocation(event) {
    const locationId = this.element.querySelector("input[name='location[id]']:checked").value;
    const locationType = this.element.querySelector("input[name='location[location_type]']:checked").value;

    this.eventLocationDetailsTarget.removeAttribute("open");

    const formData = new FormData();
    formData.append("event_location[location_id]", locationId);
    formData.append("event_location[location_type]", locationType);
    const url = `/u/${this.unitIdValue}/event_locations`;

    await post(url, { body: formData });
  }

  deleteLocation(event) {
    console.log("delete location");
    const locationElem = event.target.closest("event-location");
    locationElem.remove();
  }
}