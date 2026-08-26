import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "source", "feedback" ];
  static values = {
    text: String,
    feedbackText: { type: String, default: "Copied!" },
    feedbackDuration: { type: Number, default: 2000 }
  };

  copy(event) {
    const value = this.textValue || event.target.innerText;
    navigator.clipboard.writeText(value);
    event.preventDefault();
    this.showFeedback();
  }

  showFeedback() {
    if (!this.hasFeedbackTarget) { return; }

    if (this.originalFeedback === undefined) {
      this.originalFeedback = this.feedbackTarget.innerText;
    }
    this.feedbackTarget.innerText = this.feedbackTextValue;

    clearTimeout(this.feedbackTimeout);
    this.feedbackTimeout = setTimeout(() => {
      this.feedbackTarget.innerText = this.originalFeedback;
    }, this.feedbackDurationValue);
  }

  disconnect() {
    clearTimeout(this.feedbackTimeout);
  }
}
