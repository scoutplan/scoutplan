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
      this.closeMenu();
    }.bind(this));
  
    this.syncWithSelect();
  }

  blur() {
    // if (!this.element.classList.contains("unmatched")) return;
    this.unfilterOptions();
    this.closeMenu();
  }

  shiftPressed() {
    // do nothing
  }

  clearSelection() {
    this.element.querySelectorAll(".selected").forEach(function(elem) {
      elem.classList.remove("selected");
    });
  }

  closeMenu() {
    this.element.classList.remove("open");
  }

  openMenu() {
    this.element.classList.add("open");
  }

  // reveal all the options that were hidden by the search
  unfilterOptions() {
    this.element.querySelectorAll(".option").forEach(function(elem) {
      elem.classList.remove("hidden");
    });
  }

  // fired when the search field receives focus
  searchFocus(event) {
    this.unfilterOptions();
    this.setFocus(this.currentSelection());
    this.textTarget.select();
    this.openMenu();
  }

  hover(event) {
    this.setFocus(event.currentTarget);
  }

  // when the user clicks on an option in the proxy dropdown
  makeSelection(event) {
    this.performSelection(event.currentTarget);
  }
  
  selectFocusedOption(event) {
    this.performSelection(this.currentFocus());
    // event.stopPropagation();
    // event.preventDefault();
  }
  
  performSelection(elem) {
    if (!elem) return;
    
    elem.classList.add("selected");
    this.setFocus(elem);
    var selectedValue = elem.dataset.value;
    
    // set the value of the hidden select
    var sourceOptionElem = this.selectTarget.querySelector("option[value='" + selectedValue + "']");
    sourceOptionElem.selected = true;

    this.syncWithSelect();
    this.closeMenu();
    this.reveal
  }

  visibleOptions() {
    return this.element.querySelectorAll("li.option:not(.hidden)");
  }

  //
  // focus methods
  //
  moveFocusUp(e) {
    this.moveFocus(-1);
  }

  moveFocusDown(e) {
    this.moveFocus(1);
  }
  
  moveFocus(offset) {
    this.openMenu();
    var fe = this.currentFocus();
    var visibleOptions = this.visibleOptions();
    // var pos = visibleOptions.indexOf(fe);
    var pos = Array.prototype.indexOf.call(visibleOptions, fe);
    var targetElem = visibleOptions[pos + offset];
    if (targetElem) this.setFocus(targetElem);

    event.preventDefault();
    event.stopPropagation();
  }

  clearFocus() {
    this.element.querySelectorAll(".focused").forEach(function(elem) {
      elem.classList.remove("focused");
    });
  }
  
  setFocus(elem) {
    if (!elem) return;
    if (elem.classList.contains("hidden")) return;
    
    this.clearFocus();
    elem.classList.add("focused");
    elem.scrollIntoView({block: "nearest", inline: "nearest"});
  }
  
  currentFocus() {
    return this.element.querySelector(".focused");
  }
  //
  // end focus methods
  //

  currentSelection() {
    return this.element.querySelector(".selected");
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
    // ignore the tab, down, up, and shift keys
    var ignoreKeyCodes = [9, 40, 38, 16];
    if (ignoreKeyCodes.includes(event.keyCode)) return;

    var searchValue = this.textTarget.value.toLowerCase();

    // show/hide the proxy options based on the search value
    var proxyOptions = this.element.querySelectorAll("li.option");
    var unmatched = true;

    proxyOptions.forEach(function(proxyOptionElem) {

      var optionText = proxyOptionElem.dataset.text.toLowerCase();
      if (optionText.startsWith(searchValue)) {
        proxyOptionElem.classList.remove("hidden");
        unmatched = false;
      } else {
        proxyOptionElem.classList.add("hidden");
      }
    });

    this.element.classList.toggle("unmatched", unmatched);

    if (unmatched) {
      this.element.querySelector(".unmatched-prompt *").innerText = "\"" + this.textTarget.value + "\" will be added as a new category";
      this.clearFocus();
    }

    // select the first visible option
    var firstVisibleOption = this.visibleOptions()[0];
    this.setFocus(firstVisibleOption);
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