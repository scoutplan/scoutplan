import { DirectUpload } from "@rails/activestorage"
import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

// https://mentalized.net/journal/2020/11/30/upload-multiple-files-with-rails/
// config.active_storage.replace_on_assign_to_many = false
// https://blog.commutatus.com/understanding-rails-activestorage-direct-uploads-a4aeca7eccf

export default class extends Controller {
  static targets = [ "attachmentsList", "attachmentsWrapper", "attachmentForm", "audienceList", "audienceName",
                     "ffCheckWrapper", "fileInput", "form",
                     "recipientList", "memberTypeCheckBox", "memberStatusCheckBox", "subjectTextBox", "bodyTextArea",
                     "sendMessageButton", "sendLaterButton", "sendPreviewButton", "tempFileInput",
                     "queryInput", "searchResults" ];
  static values = { unitId: Number };

  recipientObserver = null;
  dirty = false;
  shouldSkipLeaveConfirmation = false;

  skipLeaveConfirmation() {
    this.shouldSkipLeaveConfirmation = true;
  }

  addAttachments(event) {
    this.attachmentFormTarget.requestSubmit();
  }

  confirmLeave(event) {
    if (this.shouldSkipLeaveConfirmation) { return; }

    if (this.dirty && !confirm("You have unsaved changes. Are you sure you want to leave this page?")) {
      event.preventDefault();
      event.returnValue = "";
    }
  }

  connect() {
    this.establishRecipientObserver();
    this.establishAttachmentsObserver();
    this.validate();
    this.formData = new FormData(this.formTarget);
  }

  establishRecipientObserver() {
    this.recipientObserver = new MutationObserver((mutations) => {
      this.validate();
    });
    this.recipientObserver.observe(this.recipientListTarget, { childList: true });
  }

  establishAttachmentsObserver() {
    this.attachmentObserver = new MutationObserver((mutations) => {
      this.attachmentsWrapperTarget.classList.toggle("hidden", this.attachmentsListTarget.children.length == 0);
    });
    this.attachmentObserver.observe(this.attachmentsListTarget, { childList: true });
  }

  handleKeydown(event) {
    if (event.key === "Backspace" && (event.metaKey || event.ctrlKey)) {
      this.recipientListTarget.querySelectorAll(".recipient").forEach((tag) => {
        tag.remove();
      });
    } else if (event.key === "Backspace") {
      if (this.queryInputTarget.value.length > 0) { return; }
      this.deleteLastRecipient();
      this.validate();
      return;
    }

    const current = this.searchResultsTarget.querySelector(".selected");
    if (!current) { return; }

    if (event.key === "ArrowUp") {
      var target = current.previousSibling;
      if (target == null) { target = current.parentNode.lastChild; } // wraparoun
      while(target) {
        if (target.classList.contains("contactable")) { break; }
        target = target.previousSibling;
        if (target == null) { target = current.parentNode.lastChild; } // wraparound
      }
      current.classList.remove("selected");
      target?.classList?.add("selected");
      target?.scrollIntoView({block: "center"});
      event.stopPropagation();
      event.preventDefault();
    } else if (event.key === "ArrowDown") {
      var target = current.nextSibling;
      if (target == null) { target = current.parentNode.firstChild; } // wraparound
      while(target) {
        if (target.classList.contains("contactable")) { break; }
        target = target.nextSibling;
        if (target == null) { target = current.parentNode.firstChild; } // wraparound
      }
      current.classList.remove("selected");
      target?.classList?.add("selected");
      target?.scrollIntoView({block: "center"});
      event.stopPropagation();
      event.preventDefault();
    } else if (event.key === "Enter" || event.key === "Tab") {
      this.commit();
      event.stopPropagation();
      event.preventDefault();
    } else if (event.key === "Escape") {
      this.resetQueryInput();
      event.stopPropagation();
      event.preventDefault();
    } else { return; }
  }

  deleteLastRecipient() {
    const lastElem = this.queryInputTarget.parentNode.previousSibling;
    if (!lastElem) { return; }
    lastElem.remove();
  }

  commit() {
    const current = this.searchResultsTarget.querySelector(".selected");
    const recipientTags = this.recipientListTarget.querySelectorAll(".recipient");
    const memberIds = Array.from(recipientTags).map((tag) => { return tag.dataset.recipientId; });

    const body = { "key": current.dataset.key, "member_ids": memberIds }

    post(`/u/${this.unitIdValue}/messages/commit`, { body: body, responseKind: "turbo-stream" });    

    this.markAsDirty();
    this.queryInputTarget.value = "";
    this.queryInputTarget.focus();
    this.clearResults();
  }

  deleteItem(event) {
    const target = event.target;
    target.closest(".recipient").remove();
  }

  clearResults() {
    this.searchResultsTarget.innerHTML = "";
  }

  hideRecipientList() {
    this.recipientListTarget.classList.toggle("hidden", true);
  }

  searchRecipients() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.performRecipientSearch();
    }, 50);
  }

  markAsDirty() {
    this.dirty = true;
  }

  async performRecipientSearch() {
    const recipientTags = this.recipientListTarget.querySelectorAll(".recipient");
    const memberIds = Array.from(recipientTags).map((tag) => { return tag.dataset.recipientId; });
    const body = { "query": this.queryInputTarget.value, "member_ids": memberIds }
    const response = await post(`/u/${this.unitIdValue}/messages/search`, { body: body, responseKind: "turbo-stream" });
  }

  select(event) {
    const target = event.target;
    event.preventDefault();
    this.resetQueryInput();
  }

  resetQueryInput() {
    this.queryInputTarget.value = "";
    this.searchRecipients();
  }

  toggleRecipientList(event) {
    this.recipientListTarget.classList.toggle("hidden");
    event.preventDefault();
  }

  toggleFormattingToolbar (event) {
    this.element.classList.toggle("formatting-active");
    event.preventDefault();
  }

  uploadFiles() {
    const files = this.fileInputTarget.click();
  }

  validate() {
    var valid = this.subjectTextBoxTarget.value.length > 0;
    // valid = valid && this.bodyTextAreaTarget?.value?.length > 0;
    valid = valid && this.recipientListTarget.querySelectorAll(".recipient").length > 0;

    this.sendMessageButtonTarget.disabled = !valid;
    this.sendLaterButtonTarget.disabled   = !valid;
    this.sendPreviewButtonTarget.disabled = !valid;
  }

  changeAudience(event) {
    const target = this.target;
    const audienceValue = target.dataset.messageFormAudienceValue;
    
    this.audienceListTarget.querySelectorAll("li").forEach((li) => {
      li.classList.toggle("active", false);
    });
    event.target.closest("li").classList.toggle("active", true);

    event.preventDefault();
  }

  removeAttachmentCandidate(event) {
    var elem = event.target.closest(".attachment-candidate");
    elem.remove();
  }
}
