// This Stimulus controller is used to filter a list of items based on a search query.
// It requires a searchFieldTarget and a searchItemClassValue to be defined in the controller's static targets and values.
// The searchFieldTarget is the input field that the user types into. The field will receive focus whenever it comes into view.
// The searchItemClassValue is a CSS class that is applied to each item in the list that should be filtered.
// The search method is called whenever the user types into the search field.
// It filters the list of items based on the search query.
// It shows the valueNotFoundPromptTarget if no items match the search query.
// Optionally, by providing a newValueUrl value and calling the addValue method,
// the controller can also show the newValuePromptTarget and then call an HTTP POST request to create a new value when the
// user clicks the "Add" button. Finally, the controller fires an event whenever a list item is checked or unchecked.
// Other controllers can listen for this event and respond to it.

import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class extends Controller {
  static targets = [ "searchField", "valueNotFoundPrompt", "newValuePrompt", "newValueName" ];
  static values = {
    searchItemClass: String,
    newValueUrl: String,
  };

  connect() {
    this.searchItemCssValue = this.searchItemClassValue || ".search-item";
    this.searchItems = this.element.querySelectorAll(this.searchItemCssValue);
    this.establishSearchFieldObserver();
  }

  search(event) {
    var query = this.searchFieldTarget.value;
    var hits = 0;
    var exactMatch = false;

    this.searchItems.forEach(function(searchItem) {
      if(query == "") {
        searchItem.classList.remove("hidden");
      } else if (searchItem.textContent.toLowerCase() === query.toLowerCase()) {
        exactMatch = true;
      } else if (searchItem.textContent.toLowerCase().indexOf(query.toLowerCase()) > -1) {
        searchItem.classList.remove("hidden");
        hits++;
      } else {
        searchItem.classList.add("hidden");
      }
    });

    if (this.hasValueNotFoundPromptTarget) {
      this.valueNotFoundPromptTarget.classList.toggle("hidden", hits > 0 || exactMatch || query == "");
    }

    if (this.hasNewValuePromptTarget) {
      this.newValuePromptTarget.classList.toggle("hidden", query == "" || exactMatch);
      this.newValueNameTarget.innerText = query;
    }
  }

  establishSearchFieldObserver() {
    this.searchFieldObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.searchFieldTarget.focus();
        } else {
          // this.resetTagList();
        }
      });
    });
    this.searchFieldObserver.observe(this.searchFieldTarget);
  }

  async addValue(event) {
    console.log(this.newValueUrlValue);
    var newValue = this.newValueNameTarget.innerText;
    const formData = new FormData();
    formData.append("value", newValue);
    await post(this.newValueUrlValue, { responseKind: "turbo-stream", body: formData });
  }
}
