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
    const pill = event.currentTarget
    const selected = pill.dataset.categoryId // "" means All

    this.rows.forEach((row) => {
      const show = selected === "" || row.dataset.categoryId === selected
      row.classList.toggle("filtered-hidden", !show)
    })

    this.pillTargets.forEach((p) => this.setActive(p, p === pill))
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
      badge.textContent = counts[badge.dataset.categoryId] || 0
    })
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
