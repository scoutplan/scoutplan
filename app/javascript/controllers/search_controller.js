import { Controller } from "@hotwired/stimulus"

const SEARCH_TIMEOUT = 500;

export default class extends Controller {
  static targets = [ "query" ];

  connect() {
    console.log("Search controller loaded");
  }

  show() {
    document.body.classList.add("showing-search");
    document.querySelector("#search_query_term").focus();
  }

  hide() {
    document.body.classList.remove("showing-search");
  }

  keypress() {
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

  performSearch(ctx) {
    var queryTerm = this.queryTarget.value;
    console.log("Performing search with " + queryTerm);
    
    var queryTermField = document.querySelector("#query_term");
    var queryForm = document.querySelector("#query_form");

    queryTermField.value = queryTerm;
    queryForm.submit();
  }  
}


// setTimeout((function(num){return function(){
//   callback(num);
// }
// })(i), loadDelay);​

// https://gist.github.com/charbeltabet/7a1208483785a7002c21617247d5faa3