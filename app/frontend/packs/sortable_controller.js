import Sortable from "stimulus-sortable"
import { patch } from '@rails/request.js'

export default class extends Sortable {
  get options() {
    var result = super.options;
    result['group'] = this.element.dataset.sortableGroupValue;
    return result;
  }

  end({ item, newIndex, to }) {
    if (!item.dataset.sortableUpdateUrl) return;

    const data = new FormData();
    data.append('position', newIndex);
    data.append('event_id', to.dataset.sortableToId);

    patch(item.dataset.sortableUpdateUrl, { body: data });
    // fetch(item.dataset.sortableUpdateUrl, { method: 'PATCH', body: data })
  }
}