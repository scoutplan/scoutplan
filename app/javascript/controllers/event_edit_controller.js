import { Controller } from "@hotwired/stimulus"
import { get, post } from "@rails/request.js"
// import { createPopper } from "@popperjs/core"
import { computePosition } from "https://cdn.jsdelivr.net/npm/@floating-ui/dom@1.6.10/+esm"

export default class extends Controller {
  static targets = [ "deleteform", "fileinput", "privatefileinput", "documentLibraryIds", "startsAtDate", "endsAtDate", "rsvpClosesAt", "repeatsUntilSelect",
      "submit", "categorySelect", "title", "tagSearch", "newTagPrompt", "newTagName", "tagNotFoundPrompt", "tagListWrapper"
   ];
  static values = { seasonEndDate: String, unitId: String };

  connect() {
    this.populateRepeatUntilSelectOptions();

    var reference = document.querySelector("details#tags");
    var popperTarget = document.querySelector("#tags_popup");

    computePosition(reference, popperTarget, { placement: "bottom-start" }).then(({x, y}) => {
      popperTarget.style.left = `${x}px`;
      popperTarget.style.top = `${y}px`;
    });

    this.tagSearchObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.tagSearchTarget.focus();
        } else {
          this.resetTagList();
        }
      });
    });
    this.tagSearchObserver.observe(this.tagSearchTarget);
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

  syncTagList(event) {
    var tagList = document.querySelector("#tag_list");
    var checkboxes = tagList.querySelectorAll("input[type=checkbox]");

    checkboxes.forEach(function(checkbox) {
      var tagName = checkbox.dataset.tagId;
      var labelId = `#tag_label_${tagName}`;
      var labelElem = document.querySelector(labelId);
      labelElem?.classList?.toggle("hidden", !checkbox.checked);
    });
  }

  disconnect() {
    this.tagSearchObserver.disconnect();
  }

  // addAttachmentToPendingList(filename) {
  //   var attachment_list = document.querySelector("#existing_attachments");
  //   attachment_list.insertAdjacentHTML("beforeend", `<li class="pending-attachment py-1 font-bold text-green-600">${filename} (pending)</li>`);
  // }

  toggleTags(event) {
    this.tagSearchTarget.focus();
  }

  searchTags(event) {
    var query = this.tagSearchTarget.value;
    var tagList = document.querySelector("#tag_list");
    var tags = tagList.querySelectorAll("li");
    var hits = 0;

    tags.forEach(function(tag) {
      if(query == "") {
        tag.classList.remove("hidden");
      } else if (tag.textContent.toLowerCase().indexOf(query.toLowerCase()) > -1) {
        tag.classList.remove("hidden");
        hits++;
      } else {
        tag.classList.add("hidden");
      }
    });

    this.newTagPromptTarget.classList.toggle("hidden", query == "");
    this.tagNotFoundPromptTarget.classList.toggle("hidden", hits > 0);
    this.newTagNameTarget.innerText = query;
  }

  async addTag(event) {
    var newTagName = this.newTagNameTarget.innerText;
    const unitId = this.unitIdValue;
    const url = `/u/${unitId}/tags`;
    const formData = new FormData();
    formData.append("tag[name]", newTagName);
    await post(url, { responseKind: "turbo-stream", body: formData });
    this.hideTagList();
    this.resetTagList();
  }

  deselectTag(event) {
    let tagName = event.currentTarget.dataset.tagName;
    console.log(tagName);
    let tagLabel = document.querySelector(`#tag_label_${tagName}`);
    let checkbox = document.querySelector(`#event_tag_${tagName}`);
    tagLabel.classList.add("hidden");
    checkbox.checked = false;
  }

  validate(event) {
    var valid = true;
    valid = valid && this.categorySelectTarget.value != "";
    valid = valid && this.titleTarget.value != "";
    this.submitTarget.disabled = !valid;
  }

  removeCoverPhoto() {
    
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
}