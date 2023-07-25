import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class extends Controller {
  static targets = [ "audienceSelect", "ffCheckWrapper", "recipientList", "memberTypeCheckBox", "memberStatusCheckBox" ];
  static values = { unitId: Number };

  connect() {
    this.updateRecipients();
  }

  updateRecipients() {
    const audience = this.audienceSelectTarget.value;
    const memberType = this.memberTypeCheckBoxTarget.checked ? "adults_only" : "youth_and_adults";
    const memberStatus = this.memberStatusCheckBoxTarget.checked ? "active_and_registered" : "active";
    const body = {
      "audience":      audience,
      "member_type":   memberType,
      "member_status": memberStatus,
    }

    console.log(body);

    // hide the ff check box if the audience is not everyone
    this.ffCheckWrapperTarget.classList.toggle("hidden", audience !== "everyone");

    // https://www.reddit.com/r/rails/comments/rzne63/is_it_possible_to_trigger_turbo_stream_update/

    // post a call to an endpoint to compute the recipient list

    post(`/u/${this.unitIdValue}/email/recipients`, { body: body, responseKind: "turbo-stream" });
  }

  toggleRecipientList(event) {
    this.recipientListTarget.classList.toggle("hidden");
    event.preventDefault();
  }
}
