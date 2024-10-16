import { Controller } from "@hotwired/stimulus"
import { FetchRequest } from "@rails/request.js"
export default class extends Controller {
  draggedElem = null;

  static values = { unitId: String, eventId: String };
  
  dragover(event) {
    const columnElem = event.target.closest(".member-column");

    if (columnElem == null) {
      event.dataTransfer.dropEffect = "none";
      return;
    }

    // don't drop an object into its own column
    if (columnElem == this.draggedElem.closest(".member-column")) {
      event.dataTransfer.dropEffect = "none";
      return;
    }
    
    // don't drop a unit membership into a unit membership column
    if (columnElem.id.startsWith("members") && this.draggedElem.id.startsWith("unit_membership")) {
      event.dataTransfer.dropEffect = "move";
      return;
    }

    if (!columnElem) { return;}
    
    event.preventDefault();
    event.dataTransfer.dropEffect = "move";
    const dropGroup = columnElem.dataset.dropGroup;
    if (dropGroup) {
      const dropGroupElems = document.querySelectorAll(`[data-drop-group="${dropGroup}"]`);
      dropGroupElems.forEach(function(elem) {
        elem.classList.toggle("droptarget", true);
      });
    }
    columnElem.classList.toggle("droptarget", true);
  }

  drag(event) {
    this.draggedElem = event.target;
  }

  dragend(event) {
    this.element.classList.toggle("dragging", false);
    this.element.classList.toggle("dragging-from-members", false);
    this.element.classList.toggle("dragging-from-accepted", false);
    this.element.classList.toggle("dragging-from-declined", false);    
  }

  dragenter(event) {

  }

  dragleave(event) {
    event.preventDefault();
    const columnElem = event.target.closest(".member-column");
    if (!columnElem) { return; }

    const dropGroup = columnElem.dataset.dropGroup;
    if (dropGroup) {
      const dropGroupElems = document.querySelectorAll(`[data-drop-group="${dropGroup}"]`);
      dropGroupElems.forEach(function(elem) {
        elem.classList.toggle("droptarget", false);
      });
    }    
    columnElem.classList.toggle("droptarget", false);
  }

  dragstart(event) {
    this.element.classList.toggle("dragging", true);
    const fromColumn = event.target.closest(".member-column");
    this.element.classList.toggle("dragging-from-members", fromColumn.id.startsWith("members"));
    this.element.classList.toggle("dragging-from-accepted", fromColumn.id.startsWith("rsvps_accepted"));
    this.element.classList.toggle("dragging-from-declined", fromColumn.id.startsWith("rsvps_declined"));
    event.dataTransfer.dropEffect = "move";
    event.dataTransfer.setData("text/plain", event.target.parentElement.id);
  }

  drop(event) {
    const columnElem = event.target.closest(".member-column");
    var response = null;
    if (!columnElem) { return; }
    switch(columnElem.id) {
      case "rsvps_accepted_column":
        response = "accepted";
        break;
      case "rsvps_declined_column":
        response = "declined";
        break;
      default:
        response = "delete";
        break;
    }

    const idParts = event.dataTransfer.getData("text/plain").split("_");
    const id = idParts.pop();
    const objectType = idParts.join("_");

    switch(objectType) {
      case "unit_membership":
        this.createRsvp(id, response);
        break;
      case "event_rsvp":
        this.updateRsvp(id, response);
        break;
    }

    columnElem.classList.toggle("droptarget", false);
  }

  async createRsvp(unitMembershipId, response) {
    const formData = new FormData();
    formData.append("event_rsvp[response]", response);
    formData.append("event_rsvp[unit_membership_id]", unitMembershipId);
    const request = new FetchRequest("post", this.path, { body: formData, responseKind: "turbo-stream" });
    await request.perform();
  }

  async updateRsvp(eventRsvpId, response) {
    const formData = new FormData();
    formData.append("event_rsvp[response]", response);
    const request = new FetchRequest("patch", this.path + `/${eventRsvpId}`, { body: formData, responseKind: "turbo-stream" });
    await request.perform();
  }

  get path() {
    return `/u/${this.unitIdValue}/schedule/${this.eventIdValue}/event_rsvps`;
  }
}