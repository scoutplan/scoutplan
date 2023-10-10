import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "emailField", "phoneField", "viaEmailField", "viaSmsField", "youthRsvpField" ];

  connect() {
    console.log("ProfileFormController#connect");
  }

  changeSettings(event) {
    const email = this.emailFieldTarget.value;
    const phone = this.phoneFieldTarget.value;
    const validEmail = this.validEmailAddress(email);
    const validPhone = this.validPhoneNumber(phone);
    
    this.viaEmailFieldTarget.disabled = !validEmail;
    if (!validEmail) { this.viaEmailFieldTarget.checked = false; }
    this.viaSmsFieldTarget.disabled = !validPhone;
    if (!validPhone) { this.viaSmsFieldTarget.checked = false; }

    const viaEmail = this.viaEmailFieldTarget.checked;
    const viaSms = this.viaSmsFieldTarget.checked;
    const contactable = viaEmail || viaSms;

    this.youthRsvpFieldTarget.disabled = !contactable;
    if (!contactable) {
      this.youthRsvpFieldTarget.checked = false;
    }
  }

  switchProfile(event) {
    const memberId = event.target.value;
    const url = `/profiles/${memberId}/edit`;
    window.location = url;
  }

  validPhoneNumber(phone) {
    return /^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$/im.test(phone);
  }

  validEmailAddress(email) {
    return /\S+@\S+\.\S+/.test(email);
  }
}
