import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class extends Controller {
  static targets = [ "audienceList", "audienceName", "ffCheckWrapper", "recipientList", "memberTypeCheckBox", "memberStatusCheckBox",
    "subjectTextBox", "bodyTextArea", "sendMessageButton", "sendLaterButton", "sendPreviewButton" ];
  static values = { unitId: Number };

  connect() {
    this.updateRecipients();
    this.validate();
  }

  updateRecipients() {
    // const audience = this.audienceSelectTarget.value;

    const selectedRadioButton = document.querySelector("input[type='radio']:checked");
    const audienceName = selectedRadioButton.dataset.messageFormAudienceName;
    const audience = selectedRadioButton.value;

    this.audienceNameTarget.textContent = audienceName;

    const memberType = this.memberTypeCheckBoxTarget.checked ? "adults_only" : "youth_and_adults";
    const memberStatus = this.memberStatusCheckBoxTarget.checked ? "active_and_registered" : "active";
    const body = {
      "audience":      audience,
      "member_type":   memberType,
      "member_status": memberStatus,
    }

    // hide the ff check box if the audience is not everyone
    this.ffCheckWrapperTarget.classList.toggle("hidden", audience !== "everyone");

    // https://www.reddit.com/r/rails/comments/rzne63/is_it_possible_to_trigger_turbo_stream_update/

    // post a call to an endpoint to compute the recipient list

    post(`/u/${this.unitIdValue}/email/recipients`, { body: body, responseKind: "turbo-stream" });
  }

  hideRecipientList() {
    this.recipientListTarget.classList.toggle("hidden", true);
  }

  toggleRecipientList(event) {
    this.recipientListTarget.classList.toggle("hidden");
    event.preventDefault();
  }

  toggleFormatting (event) {
    this.element.classList.toggle("formatting-active");
    event.preventDefault();
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
