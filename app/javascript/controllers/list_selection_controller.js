import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "selectableList", "selectAllButton", "deselectAllButton", "deselectSomeButton", "selectionPrompt" ];

  connect() {
  }

  selectAllVisible(event) {
    const items = Array.from(this.element.querySelectorAll(".document-item"));
    items.forEach(item => {
      if (item.checkVisibility()) {
        item.checked = true;
      }
    });
    const selectedItems = Array.from(this.element.querySelectorAll(".document-item:checked"));
    this.element.classList.toggle("selections-present", selectedItems.length > 0);
    this.selectionPromptTarget.textContent = `${selectedItems.length} selected`;
  }

  selectItem(event) {
    // multi-select
    if (event.shiftKey) {
      const items = Array.from(this.element.querySelectorAll(".document-item"));
      const lastSelected = items.findIndex(item => item.checked);
      const currentSelected = items.findIndex(item => item === event.target);
      const range = [lastSelected, currentSelected].sort();
      items.forEach((item, index) => {
        item.checked = index >= range[0] && index <= range[1];
      });
    }

    const selectedItems = Array.from(this.element.querySelectorAll(".document-item:checked"));
    this.element.classList.toggle("selections-present", selectedItems.length > 0);

    if (selectedItems.length === 0) return;

    // update prompt
    this.selectionPromptTarget.textContent = `${selectedItems.length} selected`;

    // determine tags common to all selected items
    var tags = [];
    selectedItems.forEach(function(item) {
      const taggedItem = item.closest(".tagged-item");
      const taggedItemTags = taggedItem.dataset.tags.split(",");
      tags.push(taggedItemTags);
    });
    const commonTags = this.intersection(tags);

    // show & hide tag buttons
    const tagButtons = Array.from(this.element.querySelectorAll(".tag-button"));
    tagButtons.forEach(function(item) {
      const tagName = item.dataset.tagName;
      item.classList.toggle("currently-assigned", commonTags.indexOf(tagName) === -1);
    });

    const tagListItems = Array.from(this.element.querySelectorAll(".tag-list-item"));
    tagListItems.forEach(function(item) {
      const tagName = item.dataset.tagName;
      item.classList.toggle("currently-assigned", commonTags.indexOf(tagName) !== -1);
    });    
  }

  deselectAll(event) {
    const selectedItems = Array.from(this.element.querySelectorAll(".document-item:checked"));
    selectedItems.forEach(function(item) {
      item.checked = false;
    });
    this.element.classList.toggle("selections-present", false);
  }

  hideAllTagButtons() {
    tags.forEach(function(tag) {
      tag.classList.toggle("hidden", true);
    });
  }

  intersection(a) {
    if (a.length > 2)
        return this.intersection([this.intersection(a.slice(0, a.length / 2)), this.intersection(a.slice(a.length / 2))]);

    if (a.length == 1)
        return a[0];

    return a[0].filter(function(item) {
        return a[1].indexOf(item) !== -1;
    });
  }  
}