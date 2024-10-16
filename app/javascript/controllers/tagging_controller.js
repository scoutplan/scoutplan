import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "selectableList", "selectAllButton", "deselectAllButton", "deselectSomeButton" ];

  connect() {
  }
}