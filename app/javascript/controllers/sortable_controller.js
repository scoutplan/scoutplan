import Sortable from 'stimulus-sortable'
import { patch } from '@rails/request.js'

export default class extends Sortable {
  static targets = [ "source" ];

  get options() {
    var result = super.options;
    result['group'] = this.element.dataset.sortableGroupValue;
    return result;
  }

  end({ item, newIndex, to }) {
    if (!item.dataset.sortableUpdateUrl) return;

    const data = new FormData();
    data.append('event_activity[position]', newIndex);
    data.append('event_activity[event_id]', to.dataset.sortableToId);

    patch(item.dataset.sortableUpdateUrl, { body: data });
  }
}