import { Controller } from "@hotwired/stimulus"

// Cost is opt-in, and a single price is the common case. There is no stored
// "has a cost" or "costs differ" flag: the app already reads cost_adult ==
// cost_youth as "one price per person", so this controller just keeps the two
// columns consistent with whichever toggles are showing.
export default class extends Controller {
  static targets = ["costs", "primaryLabel", "adult", "youth", "youthRow", "differsSwitch"];

  togglePaid(event) {
    const on = event.target.checked;

    this.costsTarget.classList.toggle("hidden", !on);

    if (on) {
      this.adultTarget.focus();
    } else {
      // zero rather than blank: cost_youth is NOT NULL
      this.adultTarget.value = "0";
      this.youthTarget.value = "0";
    }
  }

  toggleDiffers(event) {
    const on = event.target.checked;

    this.youthRowTarget.classList.toggle("hidden", !on);
    this.primaryLabelTarget.textContent = on ? "Adult cost" : "Cost per person";

    if (on) {
      this.youthTarget.focus();
    } else {
      this.mirror();
    }
  }

  // while one price applies, youth tracks adult so the columns stay equal and
  // the rest of the app keeps showing "per person"
  mirror() {
    if (!this.youthRowTarget.classList.contains("hidden")) { return; }

    this.youthTarget.value = this.adultTarget.value || "0";
  }
}
