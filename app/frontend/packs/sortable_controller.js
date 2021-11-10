import Sortable from "stimulus-sortable"

export default class extends Sortable {
  get options() {
    var result = super.options;
    result['group'] = this.element.dataset.sortableGroupValue;
    return result;
  }
}
