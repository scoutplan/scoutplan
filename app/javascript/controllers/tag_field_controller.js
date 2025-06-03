import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = [ "checkable-list" ];

  change({ detail: content, target }) {
    // var labelId = `#tag_label_${content.value}`;
    console.log(content);
    var labelElem = this.element.querySelector(`[data-value="${content.value}"]`);
    labelElem?.classList?.toggle("hidden", !content.checked);
  }

  remove(event) {
    const tagLabel = event.currentTarget.closest("[data-value]");
    const value = tagLabel.dataset.value;
    
    tagLabel.classList.toggle("hidden", true);
    
    if (this.hasCheckableListOutlet) {
      this.checkableListOutlet.uncheck({ detail: { value: value }});
    }
  }
}