import { Controller } from "@hotwired/stimulus"

// Radio-style category filter for the agenda list. Works entirely client-side over the
// already-rendered DOM, composing with the CSS-only "show past events" toggle:
//   - Category selection toggles `filtered-hidden` on non-matching rows.
//   - Count badges always reflect what's visible, recomputing when the past toggle flips
//     `show-past-events` on <body> (observed via MutationObserver).
const PILL_ACTIVE = ["bg-paper-900", "border-transparent", "text-paper-100"]
const PILL_INACTIVE = ["bg-paper-100", "border-paper-300", "text-paper-800", "hover:bg-paper-200"]
const BADGE_ACTIVE = ["bg-paper-700", "text-paper-100"]
const BADGE_INACTIVE = ["bg-paper-200", "text-paper-800"]

export default class extends Controller {
  static targets = ["pill", "count", "allCount", "empty"]

  connect() {
    this.rows = Array.from(this.element.querySelectorAll(".event"))
    this.selected = ""
    this.recomputeCounts()
    this.updateEmptyState()

    this.observer = new MutationObserver(() => {
      this.recomputeCounts()
      this.updateEmptyState()
    })
    this.observer.observe(document.body, { attributes: true, attributeFilter: ["class"] })
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  select(event) {
    event.preventDefault()
    this.applySelection(event.currentTarget.dataset.categoryId) // "" means All
  }

  applySelection(selected) {
    this.selected = selected

    this.rows.forEach((row) => {
      const show = selected === "" || row.dataset.categoryId === selected
      row.classList.toggle("filtered-hidden", !show)
    })

    this.pillTargets.forEach((p) => this.setActive(p, p.dataset.categoryId === selected))
    this.updateEmptyState()
  }

  recomputeCounts() {
    const showPast = document.body.classList.contains("show-past-events")
    const counts = {}
    let total = 0

    this.rows.forEach((row) => {
      if (!showPast && row.closest(".past-month")) return
      total += 1
      const id = row.dataset.categoryId
      counts[id] = (counts[id] || 0) + 1
    })

    if (this.hasAllCountTarget) this.allCountTarget.textContent = total
    this.countTargets.forEach((badge) => {
      const count = counts[badge.dataset.categoryId] || 0
      badge.textContent = count
      // Drop the pill entirely when the category has nothing in the current time range. A
      // category whose events are all in the past reappears when "Show past events" is on,
      // which the MutationObserver in connect() already re-triggers. "All" is a separate
      // target and is never hidden.
      badge.closest("li")?.classList.toggle("hidden", count === 0)
    })

    // If the active category just vanished -- its only events were past ones and the toggle was
    // switched back off -- fall back to All, so the list isn't left empty with no visible pill
    // explaining why.
    if (this.selected !== "" && (counts[this.selected] || 0) === 0) {
      this.applySelection("")
    }
  }

  updateEmptyState() {
    if (!this.hasEmptyTarget) return
    const showPast = document.body.classList.contains("show-past-events")
    const anyVisible = this.rows.some((row) => {
      const timeVisible = showPast || !row.closest(".past-month")
      return timeVisible && !row.classList.contains("filtered-hidden")
    })
    this.emptyTarget.classList.toggle("hidden", anyVisible)
  }

  setActive(pill, active) {
    pill.classList.remove(...PILL_ACTIVE, ...PILL_INACTIVE)
    pill.classList.add(...(active ? PILL_ACTIVE : PILL_INACTIVE))

    const badge = pill.querySelector(".event-filter-badge")
    if (badge) {
      badge.classList.remove(...BADGE_ACTIVE, ...BADGE_INACTIVE)
      badge.classList.add(...(active ? BADGE_ACTIVE : BADGE_INACTIVE))
    }
  }
}
