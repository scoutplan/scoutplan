import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"
import { post } from "@rails/request.js"

export default class extends Controller {
  static targets = [ "tagSearchField", "tagList", "newTagName", "newTagLabel", "tagFilterSelect" ];
  static values = { unitId: Number };

  connect() {
  }

  openMultiSelect(event) {
    this.element.classList.toggle("multi-select-enabled", true);
  }

  closeMultiSelect(event) {
    this.element.classList.toggle("multi-select-enabled", false);
  }

  deleteSelected(event) {
    const body = new FormData();
    body.append(`document_ids`, this.selectedItemIds());
    const url = `/u/${this.unitIdValue}/library/batch_delete`;
    post(url, { body: body, responseKind: "turbo-stream" });   
  }

  batchUntagSelected(event) {
    const tagButton = event.currentTarget.closest(".tag-button");
    const tagName = tagButton.dataset.tagName;
    const body = new FormData();
    body.append(`document_ids`, this.selectedItemIds());
    body.append(`tag_name`, tagName);
    const url = `/u/${this.unitIdValue}/library/batch_untag`;
    post(url, { body: body, responseKind: "turbo-stream" });
    tagButton.classList.toggle("hidden", true);
  }

  batchTagSelected(event) {
    const tagName = event.currentTarget.dataset.tagName;
    const body = new FormData();
    body.append(`document_ids`, this.selectedItemIds());
    body.append(`tag_name`, tagName);
    const url = `/u/${this.unitIdValue}/library/batch_tag`;
    post(url, { body: body, responseKind: "turbo-stream" });

    this.tagSearchFieldTarget.value = "";
    if (this.hasNewTagNameTarget) this.newTagNameTarget.classList.toggle("hidden", true);
    if (this.hasNewTagLabelTarget) this.newTagLabelTarget.textContent = "";
  }

  batchClearTags() {
    const body = new FormData();
    body.append(`document_ids`, this.selectedItemIds());
    const url = `/u/${this.unitIdValue}/library/batch_clear_tags`;
    post(url, { body: body, responseKind: "turbo-stream" });
  }

  batchNewTagSelected() {
    const tagName = this.hasNewTagLabelTarget ? this.newTagLabelTarget.textContent : this.newTagNameTarget.innerText;
    const body = new FormData();
    body.append(`document_ids`, this.selectedItemIds());
    body.append(`tag_name`, tagName);
    const url = `/u/${this.unitIdValue}/library/batch_tag`;
    post(url, { body: body, responseKind: "turbo-stream" });

    this.tagSearchFieldTarget.value = "";
    if (this.hasNewTagNameTarget) this.newTagNameTarget.classList.toggle("hidden", true);
    if (this.hasNewTagLabelTarget) this.newTagLabelTarget.textContent = "";
  }

  selectedItems() {
    return Array.from(this.element.querySelectorAll(".document-item:checked"));
  }

  selectedItemIds() {
    return this.selectedItems().map(item => item.value).join(",");
  }

  performTagSearch() {
    const search = this.tagSearchFieldTarget.value.trim();
    const tagListItems = this.tagListTarget.querySelectorAll(".tag-list-item");
    let exactMatch = false;
    tagListItems.forEach(item => {
      const tagName = item.dataset.tagName;
      const matches = search.length === 0 || tagName.toLowerCase().includes(search.toLowerCase());
      item.classList.toggle("hidden", !matches);
      if (tagName.toLowerCase() === search.toLowerCase()) exactMatch = true;
    });
    if (this.hasNewTagNameTarget) {
      this.newTagNameTarget.classList.toggle("hidden", search.length === 0 || exactMatch);
    }
    if (this.hasNewTagLabelTarget) {
      this.newTagLabelTarget.textContent = search;
    }
  }

  filterByTag(event) {
    const tagName = event.currentTarget.value;
    this.performFilter(tagName);
  }

  navigateByTag(event) {
    const tag = event.currentTarget.value;
    const url = new URL(window.location);
    console.log("Navigating to tag", tag);
    if (tag) {
      url.searchParams.set("tag", tag);
    } else {
      url.searchParams.delete("tag");
    }
    Turbo.visit(url.toString(), { action: "advance" });
  }

  performFilter(tagName) {
    console.log(tagName);
    const items = Array.from(this.element.querySelectorAll(".tagged-item"));
    items.forEach(item => {
      const tags = item.dataset.tags.split(",");
      const shouldShow = (tagName == "_all") || (tagName == "none" && item.dataset.tags == "") || (tags.indexOf(tagName) !== -1);
      item.classList.toggle("hidden", !shouldShow);
    });    
  }  

  clearFilter(event) {
    const items = Array.from(this.element.querySelectorAll(".tagged-item"));
    items.forEach(item => {
      item.classList.toggle("hidden", false);
    });
  }
}
