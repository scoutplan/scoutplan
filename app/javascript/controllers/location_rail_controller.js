import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

// Drives the Location rail's three mutually exclusive states: empty, one or
// more places, or online. Places are held in hidden nested-attribute rows keyed
// by the enum's position; nothing is persisted until the event form is saved,
// except creating a new location, which needs an id to attach.
export default class extends Controller {
  static targets = [
    "adder", "chooser", "typeChoice", "onlineChoice",
    "browser", "browserTitle", "list", "createForm", "createName",
    "addressField", "phoneField", "websiteField",
    "chip", "chipName", "chipFlag", "locationId", "destroyFlag",
    "onlineFlag", "onlineRow", "onlineUrl"
  ];

  static values = { createUrl: String, eventId: String, online: Boolean };

  connect() {
    this.activeType = null;
    this.pendingName = null;
    this.sync();
  }

  // ---- step one: pick a role, or go online -------------------------------

  chooseType(event) {
    this.activeType = event.currentTarget.dataset.locationType;
    this.closeAdder();
    this.openBrowser();
  }

  chooseOnline(event) {
    event.preventDefault();
    this.onlineFlagTarget.value = "1";
    this.closeAdder();
    this.sync();
    this.onlineUrlTarget.focus();
  }

  clearOnline() {
    this.onlineFlagTarget.value = "0";
    this.onlineUrlTarget.value = "";
    this.sync();
  }

  // ---- step two: pick a place -------------------------------------------

  openBrowser() {
    this.browserTitleTarget.textContent = this.labelFor(this.activeType);
    this.browserTarget.classList.remove("hidden");
    this.resetCreateForm();
  }

  closeBrowser() {
    this.browserTarget.classList.add("hidden");
    this.resetCreateForm();
    this.activeType = null;
  }

  select(event) {
    const button = event.currentTarget;
    this.assign({
      id: button.dataset.locationId,
      name: button.dataset.locationName,
      incomplete: button.dataset.locationIncomplete === "true"
    });
  }

  removePlace(event) {
    const type = event.currentTarget.dataset.locationType;

    this.fieldFor("locationId", type).value = "";
    this.fieldFor("destroyFlag", type).value = "1";
    this.chipFor(type).classList.add("hidden");
    this.sync();
  }

  // ---- creating a location ----------------------------------------------

  startCreate(event) {
    event.preventDefault();

    const nameEl = this.browserTarget.querySelector("[data-searchable-list-target='newValueName']");
    this.pendingName = nameEl ? nameEl.textContent.trim() : "";
    this.createNameTarget.textContent = `Create "${this.pendingName}"`;
    this.createFormTarget.classList.remove("hidden");
    this.addressFieldTarget.focus();
  }

  skipDetail(event) {
    event.preventDefault();
    this.persist({name: this.pendingName});
  }

  createWithDetail(event) {
    event.preventDefault();
    this.persist({
      name: this.pendingName,
      address: this.addressFieldTarget.value,
      phone: this.phoneFieldTarget.value,
      website: this.websiteFieldTarget.value
    });
  }

  async persist(attributes) {
    const body = new FormData();
    Object.entries(attributes).forEach(([key, value]) => {
      if (value) { body.append(`location[${key}]`, value); }
    });
    if (this.eventIdValue) { body.append("event_id", this.eventIdValue); }

    const response = await post(this.createUrlValue, {body: body, responseKind: "json"});
    if (!response.ok) { return; }

    const location = await response.json;
    this.addOption(location);
    this.assign({id: location.id, name: location.name, incomplete: location.needs_detail});
  }

  addOption(location) {
    const row = document.createElement("li");
    row.className = "search-item";
    row.innerHTML = `
      <button type="button"
              class="w-full text-left flex flex-row items-center gap-2 px-2 py-2 rounded hover:bg-paper-100 cursor-pointer"
              data-action="location-rail#select"
              data-location-id="${location.id}"
              data-location-name="${this.escape(location.name)}"
              data-location-incomplete="${location.needs_detail}">
        <i class="fa-regular fa-fw fa-location-dot text-paper-500"></i>
        <span class="truncate">${this.escape(location.name)}</span>
      </button>`;
    this.listTarget.appendChild(row);
  }

  // ---- shared ------------------------------------------------------------

  assign({id, name, incomplete}) {
    const type = this.activeType;
    if (!type) { return; }

    this.fieldFor("locationId", type).value = id;
    this.fieldFor("destroyFlag", type).value = "0";

    this.namedTarget("chipName", type).textContent = name;
    this.namedTarget("chipFlag", type).classList.toggle("hidden", !incomplete);
    this.chipFor(type).classList.remove("hidden");

    this.closeBrowser();
    this.sync();
  }

  // the three states are exclusive, so every mutation ends here
  sync() {
    const online = this.onlineFlagTarget.value === "1";
    const placeCount = this.chipTargets.filter((chip) => !chip.classList.contains("hidden")).length;

    // online withdraws the + entirely; a place withdraws the online option
    this.adderTarget.classList.toggle("hidden", online);
    this.onlineRowTarget.classList.toggle("hidden", !online);
    this.onlineChoiceTarget.classList.toggle("hidden", placeCount > 0);

    this.typeChoiceTargets.forEach((choice) => {
      const type = choice.dataset.typeFor;
      choice.disabled = !this.chipFor(type).classList.contains("hidden");
    });
  }

  // adderTarget is the <details> itself
  closeAdder() {
    this.adderTarget.removeAttribute("open");
  }

  resetCreateForm() {
    this.createFormTarget.classList.add("hidden");
    [this.addressFieldTarget, this.phoneFieldTarget, this.websiteFieldTarget]
      .forEach((field) => { field.value = ""; });
    this.pendingName = null;
  }

  chipFor(type) {
    return this.chipTargets.find((chip) => chip.dataset.locationType === type);
  }

  fieldFor(name, type) {
    return this[`${name}Targets`].find((field) => field.dataset.forType === type);
  }

  namedTarget(name, type) {
    return this[`${name}Targets`].find((el) => el.dataset.forType === type);
  }

  labelFor(type) {
    const choice = this.typeChoiceTargets.find((el) => el.dataset.typeFor === type);
    return choice ? choice.textContent.trim() : "";
  }

  escape(text) {
    const node = document.createElement("div");
    node.textContent = text;
    return node.innerHTML;
  }
}
