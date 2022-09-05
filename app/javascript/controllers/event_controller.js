import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
  }

  toggleFutureEvents(event) {
    this.toggleBodyClass(event, "showing-future-events");
    toggleMonthSections(".event-month", ".event");
  }

  togglePastEvents(event) {
    this.toggleBodyClass(event, "showing-past-events");
    document.getElementById("event_month_current_0").scrollIntoView();
  }

  toggleCancelledEvents(event) {
    this.toggleBodyClass(event, "showing-cancelled-events");
  }

  toggleRsvpEvents(event) {
    this.toggleBodyClass(event, "showing-only-rsvp-events");
  }

  toggleBulkPublish(event) {
    this.toggleBodyClass(event, "showing-only-draft-events");
  }

  toggleSideNav(event) {
    const navSelector = "#main_nav";
    var navElem = document.querySelector(navSelector);
    navElem.classList.toggle("-translate-x-full");
    // navElem.classList.toggle("-translate-x-0");
  }

  close_modal(event) {
    this.element.remove();
    this.element.closest("turbo-frame").src = undefined;
  }

  toggleBodyClass(event, className, force = null) {
    event.preventDefault();
    if (force === null) {
      document.body.classList.toggle(className);
    } else if (force) {
      document.body.classList.add(className);
    } else {
      document.body.classList.remove(className);
    }

    toggleMonthSections();
  }
}