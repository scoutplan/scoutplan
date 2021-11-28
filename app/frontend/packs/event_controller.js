import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('Events controller loaded');
  }

  toggleFutureEvents(event) {
    this.toggleBodyClass(event, 'showing-future-events');
  }

  togglePastEvents(event) {
    this.toggleBodyClass(event, 'showing-past-events');
  }

  toggleCancelledEvents(event) {
    this.toggleBodyClass(event, 'showing-cancelled-events');
    this.toggleBodyClass(event, 'showing-past-events', true)
  }

  toggleRsvpEvents(event) {
    this.toggleBodyClass(event, 'showing-only-rsvp-events');
  }

  toggleBulkPublish(event) {
    this.toggleBodyClass(event, 'showing-only-draft-events')
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
  }
}
