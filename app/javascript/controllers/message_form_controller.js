import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class extends Controller {
  static targets = [ "attachmentList", "attachmentWrapper", "attachmentForm", "audienceList", "audienceName",
                     "ffCheckWrapper", "fileInput",
                     "recipientList", "memberTypeCheckBox", "memberStatusCheckBox", "subjectTextBox", "bodyTextArea",
                     "sendMessageButton", "sendLaterButton", "sendPreviewButton", "tempFileInput",
                     "queryInput", "searchResults" ];
  static values = { unitId: Number };

  files= [];

  connect() {
    this.validate();
  }

  handleKeydown(event) {

    if (event.key === "Backspace") {
      if (this.queryInputTarget.value.length > 0) { return; }
      this.deleteLastRecipient();
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
      event.stopPropagation()
      event.preventDefault()
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
      event.stopPropagation()
      event.preventDefault()
    } else if (event.key === "Enter" || event.key === "Tab") {
      this.commit();
    } else { return; }
  }

  deleteLastRecipient() {
    const lastElem = this.queryInputTarget.parentNode.previousSibling;
    if (!lastElem) { return; }
    lastElem.remove();
  }

  async commit() {
    const current = this.searchResultsTarget.querySelector(".selected");
    this.clearResults();
    const body = { "key": current.dataset.key }
    const response = await post(`/u/${this.unitIdValue}/email/commit`, { body: body, responseKind: "turbo-stream" });    
    this.queryInputTarget.value = "";
    this.queryInputTarget.focus();
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

  async performRecipientSearch() {
    const recipientTags = this.recipientListTarget.querySelectorAll(".recipient");
    const memberIds = Array.from(recipientTags).map((tag) => { return tag.dataset.recipientId; });
    const body = { "query": this.queryInputTarget.value, "member_ids": memberIds }
    const response = await post(`/u/${this.unitIdValue}/email/search`, { body: body, responseKind: "turbo-stream" });
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

  addAttachments(event) {
    this.files.push(event.target.files);
    this.attachmentWrapperTarget.classList.toggle("hidden", false);
  }

  uploadFiles() {
    const files = this.fileInputTarget.click();
  }

  validate() {
    var valid = this.subjectTextBoxTarget.value.length > 0;
    valid = valid && this.bodyTextAreaTarget.value.length > 0;

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
}
