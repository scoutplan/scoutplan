import { Controller } from "@hotwired/stimulus"

// One upload control feeds a single attachment list. Visibility is per row:
// saved rows toggle which hidden signed_id field is enabled, pending rows are
// shuttled between the two real file inputs with DataTransfer so a file never
// has to be saved as public first.
export default class extends Controller {
  static targets = ["picker", "publicInput", "privateInput", "attachmentList", "emptyNotice"];

  connect() {
    this.pending = [];
  }

  uploadFiles(event) {
    event.preventDefault();
    event.stopPropagation();
    this.pickerTarget.click();
  }

  filesPicked() {
    for (const file of this.pickerTarget.files) {
      this.pending.push({ file: file, isPublic: true });
    }

    this.pickerTarget.value = "";
    this.renderPending();
    this.redistribute();
  }

  changeVisibility(event) {
    const row = event.target.closest("li");
    const isPublic = event.target.value === "public";

    if (row.dataset.pendingIndex !== undefined) {
      this.pending[Number(row.dataset.pendingIndex)].isPublic = isPublic;
      this.redistribute();
      return;
    }

    row.querySelector("input[data-visibility='public']").disabled = !isPublic;
    row.querySelector("input[data-visibility='private']").disabled = isPublic;
  }

  removePending(event) {
    const row = event.target.closest("li");

    this.pending.splice(Number(row.dataset.pendingIndex), 1);
    this.renderPending();
    this.redistribute();
  }

  // a file input's FileList is read-only, so rebuild each one from scratch
  redistribute() {
    const pub = new DataTransfer();
    const priv = new DataTransfer();

    this.pending.forEach((entry) => {
      (entry.isPublic ? pub : priv).items.add(entry.file);
    });

    this.publicInputTarget.files = pub.files;
    this.privateInputTarget.files = priv.files;
  }

  renderPending() {
    this.attachmentListTarget
      .querySelectorAll("li.pending-attachment")
      .forEach((row) => row.remove());

    this.pending.forEach((entry, index) => {
      this.attachmentListTarget.insertAdjacentHTML("beforeend", this.pendingRow(entry, index));
    });

    this.updateEmptyNotice();
  }

  pendingRow(entry, index) {
    const selected = (value) => (entry.isPublic === (value === "public") ? " selected" : "");

    return `
      <li class="pending-attachment py-2 flex flex-row justify-between items-center gap-4" data-pending-index="${index}">
        <div class="left flex items-center gap-2 min-w-0">
          <span class="truncate font-medium text-green-700">${this.escape(entry.file.name)}</span>
          <span class="shrink-0 text-xs text-paper-600">(pending)</span>
        </div>
        <div class="right flex items-center gap-3 shrink-0">
          <select class="border border-paper-300 rounded text-xs py-1 pl-2 pr-7 bg-white text-paper-700 focus:ring-0"
                  data-action="change->event-attachments#changeVisibility">
            <option value="public"${selected("public")}>Everyone</option>
            <option value="private"${selected("private")}>Organizers only</option>
          </select>
          <button type="button" class="text-red-500 cursor-pointer" title="Remove this file"
                  data-action="event-attachments#removePending">
            <i class="fa-solid fa-trash-alt"></i>
          </button>
        </div>
      </li>`;
  }

  updateEmptyNotice() {
    if (!this.hasEmptyNoticeTarget) { return; }

    const hasRows = this.attachmentListTarget.querySelector("li") !== null;
    this.emptyNoticeTarget.classList.toggle("hidden", hasRows);
  }

  escape(text) {
    const node = document.createElement("div");
    node.textContent = text;
    return node.innerHTML;
  }
}
