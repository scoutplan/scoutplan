import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    source: String,
    action: String,
    condition: String
  }

  sourceTargets = [];
  destinationTarget = null;
  actions = null;

  connect() {
    this.sourceValue.split(" ").forEach((sel) => {
      const thing = document.querySelector(sel);
      this.sourceTargets.push(thing);
    });

    this.actions = this.actionValue.split(" ");
    this.setUpAction("enable", this.enableAction);
    this.setUpAction("check", this.checkAction);

    // email_availability_controller flips a form-level flag that outranks these
    // conditions; it fires this so every control keyed to the form recomputes,
    // including ones whose own source fields did not change.
    this.recompute = this.recompute.bind(this);
    this.element.closest("form")?.addEventListener("duplicate-email:changed", this.recompute);
  }

  disconnect() {
    this.element.closest("form")?.removeEventListener("duplicate-email:changed", this.recompute);
  }

  recompute() {
    if (this.actions.includes("enable")) { this.enableAction(); }
    if (this.actions.includes("check")) { this.checkAction(); }
  }

  setUpAction(action, f) {
    if (!this.actions.includes(action)) { return; }
    
    this.sourceTargets.forEach((element) => {
      element.addEventListener("input", f.bind(this));
      element.addEventListener("change", f.bind(this));
      element.addEventListener("focusout", f.bind(this));
      element.addEventListener("focusin", f.bind(this));
    });
    this.enableAction();
  }

  // setUpEnableAction() {
  //   if (!this.actions.includes("enable")) { return; }
  //   // if (this.actions. "enable") { return };
    
  //   this.sourceTargets.forEach((element) => {
  //     element.addEventListener("input", this.enableAction.bind(this));
  //     element.addEventListener("change", this.enableAction.bind(this));
  //     element.addEventListener("focusout", this.enableAction.bind(this));
  //     element.addEventListener("focusin", this.enableAction.bind(this));
  //   });
  //   this.enableAction();
  // }

  // setUpDisableAction() {
  //   if (!this.actions.includes("disable")) { return; }
    
  //   this.sourceTarget.addEventListener("input", this.disableAction.bind(this));
  //   this.sourceTarget.addEventListener("change", this.disableAction.bind(this));
  //   this.sourceTarget.addEventListener("focusout", this.disableAction.bind(this));
  //   this.sourceTarget.addEventListener("focusin", this.disableAction.bind(this));
  //   this.disableAction();
  // }


  // setUpCheckAction() {
  //   if (!this.actions.includes("check")) { return; }
    
  //   this.sourceTarget.addEventListener("input", this.checkAction.bind(this));
  //   this.sourceTarget.addEventListener("change", this.checkAction.bind(this));
  //   this.sourceTarget.addEventListener("focusout", this.checkAction.bind(this));
  //   this.sourceTarget.addEventListener("focusin", this.checkAction.bind(this));
  //   this.element.addEventListener("change", this.markDirty.bind(this));
  //   this.checkAction();
  // }

  markAsDirty(event) {
    this.element.classList.toggle("dirty", true);
  }

  disableAction(event) {
    switch (this.conditionValue) {
      case "empty":
        this.disableActionEmpty();
        break;
      case "not_empty":
        this.disableActionNotEmpty();
        break;
    }
  }

  enableAction(event) {
    switch (this.conditionValue) {
      case "empty":
        this.enableActionEmpty();
        break;
      case "not_empty":
        this.enableActionNotEmpty();
        break;
      case "valid":
        this.enableActionValid();
        break;
      case "invalid":
        this.enableActionInvalid();
        break;
      default:
        this.enableActionDefault();
    }
  }  

  checkAction(event) {
    if (this.element.classList.contains("dirty")) { return; }

    switch (this.conditionValue) {
      case "not_empty":
        this.checkActionNotEmpty();
        break;
      case "valid":
        this.checkActionValid();
        break;
    }
  }

  // "not empty" is too weak for a contact preference: it ticks "via email" the
  // moment someone types a single character, committing them to a channel that
  // cannot reach them. These require the field to actually be usable.
  isValid(element) {
    if (element.value.trim() === "") { return false; }
    if (typeof element.checkValidity === "function" && !element.checkValidity()) { return false; }

    // The browser accepts "calvin@n" for type=email — a bare hostname is legal
    // per the HTML spec — but that address cannot receive mail, so it must not
    // be enough to tick "via email". Require a dotted domain.
    // Mirrored in email_availability_controller; keep the two in step.
    if (element.type === "email") {
      return /^[^\s@]+@[^\s@]+\.[A-Za-z]{2,}$/.test(element.value.trim());
    }

    // type=tel gets no format checking at all, so require enough digits to dial
    if (element.type === "tel") { return element.value.replace(/\D/g, "").length >= 10; }

    return true;
  }

  allSourcesValid() {
    return this.sourceTargets.every((element) => this.isValid(element));
  }

  // email_availability_controller marks the form when the address is already on
  // the roster; nothing keyed to that form may enable itself until it clears.
  blocked() {
    return this.element.closest("form")?.classList.contains("has-duplicate-email") === true;
  }

  enableActionValid() {
    this.element.disabled = this.blocked() || !this.allSourcesValid();
  }

  checkActionValid() {
    this.element.checked = !this.blocked() && this.allSourcesValid();
  }

  enableActionNotEmpty() {
    this.element.disabled = this.blocked();
    if (this.element.disabled) { return; }

    this.sourceTargets.forEach((element) => {
      if (element.value == "") {
        this.element.disabled = true;
        return;
      }
    });
  }

  enableActionEmpty() {
    this.element.disabled = this.sourceTarget.value == "";
  }

  disableActionNotEmpty() {
    this.element.disabled = this.sourceTarget.value != "";
  }

  disableActionEmpty() {
    this.element.disabled = this.sourceTarget.value == "";
  }

  checkActionNotEmpty() {
    this.element.checked = true;
    this.sourceTargets.forEach((element) => {
      if (element.value == "") {
        this.element.checked = false;
        return;
      }
    });
  }
}