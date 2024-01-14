import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "select", "name", "list" ];

  add(event) {
    const name = this.nameTarget.value;

    // Add to select
    // const option = document.createElement("option");
    const option = new Option(name, name, true, true);
    // option.text = name;
    // option.value = name;
    this.selectTarget.add(option);
    
    // Add to list
    const li = document.createElement("li");
//    li.innerHTML = `<svg class="svg-inline--fa fa-clock mr-2 text-emerald-500" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="clock" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" data-fa-i2svg=""><path fill="currentColor" d="M256 512C114.6 512 0 397.4 0 256S114.6 0 256 0S512 114.6 512 256s-114.6 256-256 256zM232 120V256c0 8 4 15.5 10.7 20l96 64c11 7.4 25.9 4.4 33.3-6.7s4.4-25.9-6.7-33.3L280 243.2V120c0-13.3-10.7-24-24-24s-24 10.7-24 24z"></path></svg>`;
    li.innerHTML += name;
    this.listTarget.appendChild(li);  
    
    // Clear input
    this.nameTarget.value = "";
    event.preventDefault();
  }
}