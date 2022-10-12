import { Controller } from "@hotwired/stimulus"

const SEARCH_TIMEOUT = 500;

export default class extends Controller {
  static targets = [ "query" ];

  connect() {
    console.log("Autocomplete controller connected");
  }

  show() {

  }

  hide() {

  }

  search(event) {
    var queryTerm = this.queryTarget.value;
    if (queryTerm.length < 3) { return; }
    console.log("Performing search with " + queryTerm);
  }

  oldsearch(event) {
    if (event.keyCode == 27) {
      this.hide();
      return;
    }
    clearTimeout(this.timeout);
    this.timeout = setTimeout(function() {
      // this.performSearch();  // <- for some reason this doesn't work
      var queryTerm = document.querySelector("#search_query_term").value;
      console.log("Performing search with " + queryTerm);
      
      var queryTermField = document.querySelector("#query_term");
      var queryForm = document.querySelector("#query_form");
  
      queryTermField.value = queryTerm;
      document.querySelector("#query_submit").click();
    }, 250);
  }
}
