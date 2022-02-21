import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "left", "right", "scrollable" ];

  initialize() {

  }
  
  connect() {
    console.log("Paged scroll connected!");
  }
}