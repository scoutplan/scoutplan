import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    source: String,
    action: String,
    condition: String
  }

  sourceTarget = null;
  actions = null;

  connect() {
    this.sourceTarget = document.querySelector(this.sourceValue);
    this.actions = this.actionValue.split(" ");
    this.setUpDisableAction();
    this.setUpEnableAction();
    this.setUpCheckAction();
  }

  setUpEnableAction() {
    if (!this.actions.includes("enable")) { return; }
    // if (this.actions. "enable") { return };
    
    this.sourceTarget.addEventListener("input", this.enableAction.bind(this));
    this.sourceTarget.addEventListener("change", this.enableAction.bind(this));
    this.sourceTarget.addEventListener("focusout", this.enableAction.bind(this));
    this.sourceTarget.addEventListener("focusin", this.enableAction.bind(this));
    this.enableAction();
  }

  setUpDisableAction() {
    if (!this.actions.includes("disable")) { return; }
    
    this.sourceTarget.addEventListener("input", this.disableAction.bind(this));
    this.sourceTarget.addEventListener("change", this.disableAction.bind(this));
    this.sourceTarget.addEventListener("focusout", this.disableAction.bind(this));
    this.sourceTarget.addEventListener("focusin", this.disableAction.bind(this));
    this.disableAction();
  }


  setUpCheckAction() {
    if (!this.actions.includes("check")) { return; }
    
    this.sourceTarget.addEventListener("input", this.checkAction.bind(this));
    this.sourceTarget.addEventListener("change", this.checkAction.bind(this));
    this.sourceTarget.addEventListener("focusout", this.checkAction.bind(this));
    this.sourceTarget.addEventListener("focusin", this.checkAction.bind(this));
    this.checkAction();
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
    switch (this.conditionValue) {
      case "not_empty":
        this.checkActionNotEmpty();
        break;
    }
  }  

  enableActionNotEmpty() {
    this.element.disabled = this.sourceTarget.value == "";
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
    this.element.checked = this.sourceTarget.value != "";
  }
}