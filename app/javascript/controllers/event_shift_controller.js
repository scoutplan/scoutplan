import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class extends Controller {
  static targets = [ "select", "name", "list", "eventShiftName" ];

  async addOption(event) {
    const name = window.prompt("Option name", "");
    if (!name) { return; }

    const option = document.createElement("option");
    const count = this.element.querySelectorAll(".event-shift-item").length;
    console.log(count);

    const formData = new FormData();
    formData.append("event_shift[name]", name);
    formData.append("event_shift_counter", count);
    const url = `/event_shifts`;

    await post(url, { body: formData, responseKind: "turbo-stream" });
  }

  renameEventShifts(event) {
    const newName = window.prompt("Enter new name", "Time slots");
    if (!newName) { return; }

    const labelElem = this.element.querySelector("#event_shift_switch .label-text");
    labelElem.textContent = newName;
    this.eventShiftNameTarget.value = newName;
  }

  renameOption(event) {
    const optionElem = event.target.closest(".event-shift-item");
    const oldName = optionElem.textContent;
    const newName = window.prompt("Enter new name", oldName);
    if (!newName) { return; }

    const nameElem = optionElem.querySelector(".event-shift-name");
    nameElem.value = newName;

    const displayElem = optionElem.querySelector(".event-shift-display-name");
    displayElem.textContent = newName;
  }

  removeOption(event) {
    const shiftElem = event.target.closest(".event-shift-item");
    shiftElem.classList.toggle("hidden", true);

    const destroyElem = shiftElem.querySelector(".event-shift-destroy");
    destroyElem.value = "1";
  }
}