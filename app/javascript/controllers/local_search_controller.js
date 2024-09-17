import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "query" ];

  perform() {
    const query = this.queryTarget.value;
    this.element.classList.toggle("searching", query.length > 0);

    const searchables = this.element.querySelectorAll(".search-value");

    searchables.forEach((searchable) => {
      const wrapper = searchable.closest(".search-wrapper");
      wrapper.classList.remove("search-match");

      if (query.length > 0 && searchable.innerText.toLowerCase().includes(query.toLowerCase())) {
        wrapper.classList.add("search-match");
      }
    });
  }
}
