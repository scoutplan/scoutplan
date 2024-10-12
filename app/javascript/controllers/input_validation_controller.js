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
    // this.setUpDisableAction();
    // this.setUpCheckAction();
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
    }
  }  

  enableActionNotEmpty() {
    this.element.disabled = false;
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