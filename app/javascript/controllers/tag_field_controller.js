import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = [ "checkable-list" ];

  change({ detail: content, target }) {
    var labelId = `#tag_label_${content.value}`;
    var labelElem = document.querySelector(labelId);
    labelElem?.classList?.toggle("hidden", !content.checked);
  }

  remove(event) {
    let tagName = event.currentTarget.dataset.tagName;
    let tagLabel = document.querySelector(`#tag_label_${tagName}`);
    tagLabel.classList.toggle("hidden", true);
    // this.dispatch("remove", { detail: { value: tagName }});
    if (hasCheckableListOutlet) {
      this.checkableListOutlet.uncheck({ detail: { value: tagName }});
    }
  }
}