import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

// Tells an organiser that an address is already on the roster while they are
// still typing, rather than letting the save fail. Two parents sharing an
// address is the common way in: the second one collides with the first,
// because a User is unique on email.
//
// While an address is a duplicate this controller owns the form's submit
// state: it marks the form, and input_validation_controller refuses to enable
// anything on a marked form.
export default class extends Controller {
  static targets = ["field", "message"];
  static values = { url: String, debounce: { type: Number, default: 400 } };

  // Mirrored in input_validation_controller; keep the two in step. A bare
  // hostname ("calvin@n") satisfies type=email but cannot receive mail.
  static EMAIL = /^[^\s@]+@[^\s@]+\.[A-Za-z]{2,}$/;

  connect() {
    this.lastChecked = null;
  }

  disconnect() {
    clearTimeout(this.timer);
    this.clear();
  }

  check() {
    clearTimeout(this.timer);
    this.timer = setTimeout(() => this.lookup(), this.debounceValue);
  }

  async lookup() {
    const email = this.fieldTarget.value.trim();

    // nothing useful to say about a blank or half-typed address
    if (!this.constructor.EMAIL.test(email)) { return this.clear(); }
    if (email === this.lastChecked) { return; }

    this.lastChecked = email;

    const response = await get(this.urlValue, { query: { email: email }, responseKind: "json" });
    if (!response.ok) { return this.clear(); }

    const result = await response.json;
    result.available ? this.clear() : this.warn(result.message);
  }

  warn(message) {
    this.messageTarget.textContent = message;
    this.messageTarget.classList.remove("hidden");
    this.fieldTarget.classList.add("border-red-400");

    this.form?.classList.add("has-duplicate-email");

    // an address that belongs to someone else is not a channel for this member
    if (this.emailSwitch) {
      this.emailSwitch.checked = false;
      this.emailSwitch.disabled = true;
    }

    if (this.submit) { this.submit.disabled = true; }

    this.announce();
  }

  clear() {
    this.messageTarget.textContent = "";
    this.messageTarget.classList.add("hidden");
    this.fieldTarget.classList.remove("border-red-400");

    this.form?.classList.remove("has-duplicate-email");
    if (this.emailSwitch) { this.emailSwitch.disabled = false; }

    // hand the decision back to input_validation rather than second-guessing
    // its own conditions about names and address validity
    this.announce();
  }

  announce() {
    this.form?.dispatchEvent(new CustomEvent("duplicate-email:changed"));
  }

  get form() {
    return this.element.closest("form");
  }

  get emailSwitch() {
    return this.form?.querySelector("#settings_communication_via_email");
  }

  get submit() {
    return this.form?.querySelector("#accept");
  }
}
