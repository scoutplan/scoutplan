// Stimulus controller for autocomplete

import { Controller } from "@hotwired/stimulus"

const SEARCH_TIMEOUT = 500;
const ACTIVE_CLASS = "autocomplete-active";

export default class extends Controller {
  static targets = [ "query", "wrapper", "results", "selections" ];

  connect() {
    console.log("Autocomplete controller connected");
  }

  show() {
    this.wrapperTarget.classList.add(ACTIVE_CLASS);
  }

  hide() {
    this.wrapperTarget.classList.remove(ACTIVE_CLASS);
  }

  remove(event) {

  }

  search(event) {
    if (event.keyCode == 27) {
      this.hide();
      this.queryTarget.value = "";
      return;
    }

    var queryTerm = this.queryTarget.value.toUpperCase();
    if (queryTerm.length < 3) {
      this.hide();
      return; 
    }

    this.show();

    var rows = this.resultsTarget.querySelectorAll("li");
    rows.forEach(function(row) {
      if (row.classList.contains("existing")) { return; }

      var text = row.innerText.toUpperCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
      if (text.indexOf(queryTerm) > -1) {
        row.classList.remove("hidden");
      } else {
        row.classList.add("hidden");
      }
    });
  }

  select(event) {
    var row = event.currentTarget;
    var memberId = row.dataset.autocompleteValue;
    this.hide();
  }
}
