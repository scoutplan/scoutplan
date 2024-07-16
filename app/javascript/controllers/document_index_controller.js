import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class extends Controller {
  static targets = [ "tagSearchField", "tagList", "newTagName" ];
  static values = { unitId: Number };

  connect() {
    console.log("document-index controller connected");
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
    event.currentTarget.classList.toggle("hidden", true);

    this.tagListTarget.classList.toggle("hidden", true);
    this.tagSearchFieldTarget.value = "";
    this.newTagNameTarget.innerText = "";
  }

  batchNewTagSelected(event) {
    const tagName = this.newTagNameTarget.innerText;
    const body = new FormData();
    body.append(`document_ids`, this.selectedItemIds());
    body.append(`tag_name`, tagName);
    const url = `/u/${this.unitIdValue}/library/batch_tag`;
    post(url, { body: body, responseKind: "turbo-stream" });
    event.currentTarget.classList.toggle("hidden", true);

    this.tagListTarget.classList.toggle("hidden", true);
    this.tagSearchFieldTarget.value = "";
    this.newTagNameTarget.innerText = "";
  }

  selectedItems() {
    return Array.from(this.element.querySelectorAll(".document-item:checked"));
  }

  selectedItemIds() {
    return this.selectedItems().map(item => item.value).join(",");
  }

  performTagSearch() {
    const search = this.tagSearchFieldTarget.value;
    const tagList = this.tagListTarget;
    tagList.classList.toggle("hidden", search.length === 0);
    const tagListItems = tagList.querySelectorAll(".tag-list-item");
    tagListItems.forEach(item => {
      const tagName = item.dataset.tagName;
      console.log(`tag name: ${tagName}`);
      item.classList.toggle("hidden", !tagName.includes(search));
    });
    this.newTagNameTarget.innerText = search;
  }

  filterByTag(event) {
    const tagName = event.currentTarget.value;
    const items = Array.from(this.element.querySelectorAll(".tagged-item"));
    items.forEach(item => {
      const tags = item.dataset.tags.split(",");
      item.classList.toggle("hidden", tagName != "_all" && tags.indexOf(tagName) === -1);
    });
  }

  clearFilter(event) {
    const items = Array.from(this.element.querySelectorAll(".tagged-item"));
    items.forEach(item => {
      item.classList.toggle("hidden", false);
    });
  }
}
