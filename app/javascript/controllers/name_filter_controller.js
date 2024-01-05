import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "termTextField", "container" ];

  connect() {
    console.log(this.element);
  }

  filterNames(event) {
    const input = this.termTextFieldTarget;
    const term = input.value.toUpperCase();
    console.log("filtering names for term: " + term);
    if (term.length == 0) {
      this.element.classList.toggle("filtering-names", false);
      return;
    }

    var filterableItems = this.element.querySelectorAll(".filterable-item");
    filterableItems.forEach(function(item) {
      const nameElem = item.querySelector('.filterable-name');
      const name = nameElem.innerText.normalize("NFD").replace(/[\u0300-\u036f]/g, ""); // the normalize and replace voodoo converts diacriticals to undecorated letters, e.g. ñ -> n
      const isMatch = name.toUpperCase().indexOf(term) > -1;
      item.classList.toggle("filtered-out", !isMatch);
      item.classList.toggle("filtered-in", isMatch);
    });

    this.element.classList.toggle("filtering-names", true);
    console.log(this.element);
  }
}
