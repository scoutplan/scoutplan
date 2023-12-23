import { Controller } from "@hotwired/stimulus"
import { FetchRequest } from "@rails/request.js"
export default class extends Controller {
  draggedElem = null;

  static values = { unitId: String, eventId: String };
  
  dragover(event) {
    const columnElem = event.target.closest(".member-column");
    console.log(columnElem);

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
    
    event.preventDefault();
    event.dataTransfer.dropEffect = "move";
    columnElem?.classList?.toggle("droptarget", true);  
  }

  drag(event) {
    this.draggedElem = event.target;
  }

  dragenter(event) {

  }

  dragleave(event) {
    event.preventDefault();
    const columnElem = event.target.closest(".member-column");
    columnElem?.classList?.toggle("droptarget", false);
  }

  dragstart(event) {
    event.dataTransfer.dropEffect = "move";
    event.dataTransfer.setData("text/plain", event.target.parentElement.id);
  }

  drop(event) {
    const columnElem = event.target.closest(".member-column");
    var response = null;
    if (!columnElem) { return; }
    console.log("Dropped " + event.dataTransfer.getData("text/plain") + " onto " + columnElem.id);
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

    event.target.classList.toggle("droptarget", false);
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