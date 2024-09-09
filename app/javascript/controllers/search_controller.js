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
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => { this.search() }, 250);
  }

  search() {
    const formData = new FormData();
    formData.append("query", this.queryTarget.value);
    const response = post(this.urlValue, { body: formData, responseKind: "turbo-stream" });
  }  
}
