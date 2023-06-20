import { Controller } from "@hotwired/stimulus"



export default class extends Controller {
  static targets = [ "text", "select" ];

  connect() {

    
    // this.textTarget.addEventListener("blur", function(e) {
    //   e.target.closest(".fancy-select").classList.remove("open");
    // });
  
    var disclosureElem = this.element.querySelector(".disclosure");
    disclosureElem.addEventListener("click", function(e) {
      e.preventDefault();
      e.stopPropagation();
      e.target.closest(".fancy-select").classList.toggle("open");
    });
  
    // did the user click outside the fancy-select?
    // https://stackoverflow.com/a/43405204/6756943
    document.addEventListener("click", function(e) {

      // if the click is inside the fancy-select, ignore it...
      if (e.target.closest(".fancy-select")) {
        return;
      }
  
      // ...otherwise, close up shop
      console.log("click outside");
      this.closeMenu();
    }.bind(this));
  
    this.syncWithSelect();
  }

  clearFocus() {
    this.element.querySelectorAll(".focused").forEach(function(elem) {
      elem.classList.remove("focused");
    });
  }

  clearSelection() {
    this.element.querySelectorAll(".selected").forEach(function(elem) {
      elem.classList.remove("selected");
    });
  }

  closeMenu() {
    this.element.querySelector(".fancy-select").classList.remove("open");
  }

  openMenu() {
    this.element.querySelector(".fancy-select").classList.add("open");
    var fancySelectElem = event.target.closest(".fancy-select");
    var selectedElem = fancySelectElem.querySelector(".selected");
    selectedElem?.scrollIntoView({ block: "end" });    
  }

  unfilterOptions() {
    this.element.querySelectorAll(".option").forEach(function(elem) {
      elem.classList.remove("hidden");
    });
  }

  searchFocus(event) {
    this.unfilterOptions();
    this.textTarget.select();
    this.openMenu();
  }

  hover() {
    this.clearFocus();
    this.element.classList.add("focused");
  }

  // when the user clicks on an option in the proxy dropdown
  makeSelection(event) {
    var selectedValue = event.currentTarget.dataset.value;
    event.currentTarget.classList.add("selected");
    event.currentTarget.classList.add("focused");
    console.log(event.currentTarget);

    // set the value of the hidden select
    var sourceOptionElem = this.selectTarget.querySelector("option[value='" + selectedValue + "']");
    sourceOptionElem.selected = true;

    this.syncWithSelect();
    this.closeMenu();
    this.reveal
  }

  moveUp() {
    var targetElem = this.focusedElem().previousSibling(focusedElem, ":not(.hidden)");
    targetElem?.classList.add("focused");
  }

  moveDown() {
    var targetElem = this.focusedElem().nextSibling(focusedElem, ":not(.hidden)");
    targetElem?.classList.add("focused");
  }

  focusedElem() {
    return this.element.querySelector(".focused");
  }

  previousSibling(elem, selector) {
    if (!elem) return;
    var sibling = elem.previousSibling;
    while (sibling) {
      if (sibling.matches(selector)) {
        return sibling;
      }
      sibling = sibling.previousSibling;
    }
  }

  nextSibling(elem, selector) {
    if (!elem) return;
    var sibling = elem.nextSibling;
    while (sibling) {
      if (sibling.matches(selector)) {
        return sibling;
      }
      sibling = sibling.nextSibling;
    }
  }  
  
  // see https://tailwindui.com/components/application-ui/forms/comboboxes for inspiration
  search(event) {
    if (event.keyCode == 9) return;

    var searchValue = this.textTarget.value.toLowerCase();

    // show/hide the proxy options based on the search value
    var proxyOptions = this.element.querySelectorAll("li");
    proxyOptions.forEach(function(proxyOptionElem) {
      var optionText = proxyOptionElem.dataset.text.toLowerCase();
      if (optionText.includes(searchValue)) {
        proxyOptionElem.classList.remove("hidden");
      } else {
        proxyOptionElem.classList.add("hidden");
      }
    });

    // select the first visible option
    var firstVisibleOption = this.element.querySelector("li:not(.hidden)");
    if (firstVisibleOption) {
      this.clearSelection();
      firstVisibleOption.classList.add("focused");
    }
  }

  syncWithSelect() {
    var selectedOptionElem = this.selectTarget.options[this.selectTarget.selectedIndex];
    
    // copy the display name into the text input
    this.textTarget.value = selectedOptionElem.text;
    
    // mark the proxy option as selected
    this.clearSelection();
    var proxyOptionElem = this.element.querySelector("li[data-value='" + selectedOptionElem.value + "']");
    proxyOptionElem?.classList?.add("selected");
  }
}