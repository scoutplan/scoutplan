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
    // this.updateRecipients();
    this.validate();
  }

  // updateRecipients() {
  //   console.log("updateRecipients");
  //   const selectedRadioButton = document.querySelector("input[type='radio']:checked");
  //   const audience = selectedRadioButton.value;
  //   const memberType = this.memberTypeCheckBoxTarget.checked ? "adults_only" : "youth_and_adults";
  //   const memberStatus = this.memberStatusCheckBoxTarget.checked ? "active_and_registered" : "active";
  //   const timeout = null;
  //   const delay = 5000; // ms
    
  //   var audienceName = selectedRadioButton.dataset.messageFormAudienceName;

  //   if (audience === "everyone") {
  //     if (memberStatus === "active_and_registered") {
  //       audienceName = "All " + audienceName;
  //     } else {
  //       audienceName = "Active " + audienceName;
  //     } 
  //   }

  //   if (memberType === "adults_only") {
  //     audienceName = "Adult " + audienceName;
  //   }

  //   this.audienceNameTarget.textContent = audienceName;    

  //   // hide the ff check box if the audience is not everyone
  //   this.ffCheckWrapperTarget.classList.toggle("hidden", audience !== "everyone");

  //   // https://www.reddit.com/r/rails/comments/rzne63/is_it_possible_to_trigger_turbo_stream_update/

  //   // post a call to an endpoint to compute the recipient list

  //   const body = {
  //     "audience":      audience,
  //     "member_type":   memberType,
  //     "member_status": memberStatus,
  //   }    

  //   post(`/u/${this.unitIdValue}/email/recipients`, { body: body, responseKind: "turbo-stream" });
  // }

  handleKeydown(event) {
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
    } else if (event.key === "Backspace") {
      this.deleteLastRecipient();
    } else if (event.key === "Enter") {
      this.commit();
    } else { return; }
  }

  deleteLastRecipient() {
    const lastElem = this.searchResultsTarget.lastChild;
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
    const body = { "query": this.queryInputTarget.value }
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
    console.log(this.files);
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
