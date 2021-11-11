import { Controller } from '@hotwired/stimulus'
import Sortable from 'sortablejs'
import { patch } from '@rails/request.js'

export default class extends Controller {
  initialize() {
    this.end = this.end.bind(this)
  }

  connect() {
    this.sortable = new Sortable(this.element, {
      onEnd: this.end
    });
  }

  disconnect() {
    this.sortable.destroy();
    this.sortable = undefined;
  }

  end({ item, newIndex, to }) {
    if (!item.dataset.sortableUpdateUrl) return;

    const data = new FormData();
    data.append('position', newIndex);
    data.append('event_id', to);

    patch(item.dataset.sortableUpdateUrl, { body: data });
  }
}