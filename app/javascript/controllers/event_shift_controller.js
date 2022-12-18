import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "select", "name" ];

  add(event) {
    const name = this.nameTarget.value;
    const option = document.createElement("option");
    option.text = name;
    option.value = name;
    this.selectTarget.add(option);
    this.selectTarget.value = name;
    this.nameTarget.value = "";
    event.preventDefault();
  }
}