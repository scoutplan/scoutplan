// Stimulus controller for autocomplete

import { Controller } from "@hotwired/stimulus"

const SEARCH_TIMEOUT = 500;
const ACTIVE_CLASS = "autocomplete-active";

export default class extends Controller {
  static targets = [ "query", "wrapper", "results", "selections", "list" ];

  addPill(memberName, memberId) {
    var pill = document.createElement("span");
    pill.classList.add("px-2", "py-1", "bg-sky-100", "font-bold", "rounded", "text-sky-600", "inline-block", "whitespace-nowrap", "items-center");
    pill.innerText = memberName;
    pill.appendChild(this.removeButton(memberId));
    pill.dataset.memberId = memberId;
    this.listTarget.appendChild(pill);
  }

  addSelection(memberName, memberId) {
    var newOption = new Option(memberName, memberId, true, true);
    this.selectionsTarget.add(newOption, undefined);
    this.queryTarget.focus();
  }

  show() {
    this.wrapperTarget.classList.add(ACTIVE_CLASS);
  }

  hide() {
    this.wrapperTarget.classList.remove(ACTIVE_CLASS);
  }

  remove(event) {
    var button = event.currentTarget;
    var pill = event.currentTarget.closest("span");
    var memberId = button.dataset.autocompleteValue;
    var option = this.selectionsTarget.querySelector(`option[value="${memberId}"]`);
    option.selected = false;
    pill.remove();
  }

  // button.ml-2(type="button" data-action="click->autocomplete#remove" data-autocomplete-target="option" data-autocomplete-value="#{organizer.unit_membership_id}")
    // i.fa-solid.fa-times-circle

  removeButton(memberId) {
    var button = document.createElement("button");
    button.classList.add("ml-2");
    button.dataset.action = "click->autocomplete#remove";
    button.dataset.autocompleteValue = memberId;

    var icon = document.createElement("i");
    icon.classList.add("fa-solid", "fa-times-circle");
    button.appendChild(icon);

    return button;
  }

  reset() {
    this.queryTarget.value = "";
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

  // when an item is selected, add it to the list of selections,
  // add a pill, and then clear out the search box
  select(event) {
    event.preventDefault();
    var selection = event.currentTarget
    var memberId = selection.dataset.autocompleteValue;
    
    this.addSelection(selection.innerText, memberId);
    this.addPill(selection.innerText, memberId);
    
    this.reset();
    this.hide();
  }
}
