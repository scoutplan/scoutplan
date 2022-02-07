import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('Event controller loaded');
  }

  toggleFutureEvents(event) {
    this.toggleBodyClass(event, 'showing-future-events');
  }

  togglePastEvents(event) {
    this.toggleBodyClass(event, 'showing-past-events');
  }

  toggleCancelledEvents(event) {
    this.toggleBodyClass(event, 'showing-cancelled-events');
  }

  toggleRsvpEvents(event) {
    this.toggleBodyClass(event, 'showing-only-rsvp-events');
  }

  toggleBulkPublish(event) {
    this.toggleBodyClass(event, 'showing-only-draft-events');
  }

  toggleSideNav(event) {
    const navSelector = '#main_nav';
    var navElem = document.querySelector(navSelector);
    navElem.classList.toggle('hidden');
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

    hideEmptyMonthHeaders();
  }
}