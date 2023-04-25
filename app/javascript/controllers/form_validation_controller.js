import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  requiredFields = [];
  submitButton;

  connect() {
    this.requiredFields = this.element.querySelectorAll("[required]");
    this.submitButton = this.element.querySelector("input[type=submit], button[type=submit] ");

    this.submitButton.dataset.action = "form-validation#validate";

    // this.element.querySelectorAll("input").forEach(function(elem) {
    //   elem.dataset.action = "form-validation#validate";
    // });

    // this.validate();
  }

  validate(event) {
    var invalidCount = 0;
    var t = this;

    this.requiredFields.forEach(function(elem) {
      var value = (elem.type === "radio" ? t.radioValue(elem) : elem.value);
      
      if (value === "") {
        elem.classList.add("is-invalid");
        invalidCount++;
      } else {
        elem.classList.remove("is-invalid");
      }
    });

    console.log("invalidCount: " + invalidCount);

    if (invalidCount > 0) {
      event.preventDefault();
      event.stopPropagation();
    }

    // this.submitButton.disabled = (invalidCount > 0);
  }

  radioValue(radio) {
    var name = radio.name;
    var selector = `input[type='radio'][name='${name}']:checked`;
    var selected = document.querySelector(selector);
    return (selected === null) ? "" : selected.value;
  }
}