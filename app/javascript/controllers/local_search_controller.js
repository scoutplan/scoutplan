import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class extends Controller {
  static targets = [ "query" ];
  static values = { 
    url: String 
  };

  show() {
    document.body.classList.add("showing-search");
    document.querySelector("#search_query_term").focus();
  }

  hide() {
    document.body.classList.remove("showing-search");
  }

  perform() {
    const query = this.queryTarget.value;
    this.element.classList.toggle("searching", query.length > 0);

    const searchables = this.element.querySelectorAll(".search-value");
    searchables.forEach((searchable) => {
      const wrapper = searchable.closest(".search-wrapper");
      if (searchable.innerText.toLowerCase().includes(query.toLowerCase())) {
        wrapper.classList.add("search-match");
      } else {
        wrapper.classList.remove("search-match");
      }
    });
  }
}
