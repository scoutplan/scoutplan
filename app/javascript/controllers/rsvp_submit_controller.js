import { Controller } from "@hotwired/stimulus"

const SPINNER_MS   = 1500
const CHECKMARK_MS = 1000
const FADEOUT_MS   = 300

export default class extends Controller {
  static targets = ["button", "overlay", "icon", "message"]

  submit() {
    this.buttonTarget.disabled = true
    this.overlayTarget.classList.remove("hidden")
    this.submittedAt = Date.now()
    this.pendingStreams = []
    this.flushScheduled = false
    this.streamsReady = false

    document.addEventListener("turbo:before-stream-render", this.delayStream)

    setTimeout(() => this.showCheckmark(), SPINNER_MS)
  }

  showCheckmark() {
    const oldIcon = this.iconTarget
    const newIcon = document.createElement("i")
    newIcon.setAttribute("class", "fa-solid fa-circle-check text-brand-500 fa-2xl animate-checkmark-pop")
    newIcon.setAttribute("data-rsvp-submit-target", "icon")
    oldIcon.replaceWith(newIcon)
    this.messageTarget.textContent = "RSVP Sent!"

    setTimeout(() => this.dismiss(), CHECKMARK_MS)
  }

  dismiss() {
    const modal = this.element.closest("[data-controller='popup']") || this.element.parentElement
    modal.classList.add("opacity-0", "transition-opacity")
    modal.style.transitionDuration = `${FADEOUT_MS}ms`

    setTimeout(() => {
      this.flushStreams()
      modal.remove()
    }, FADEOUT_MS)
  }

  delayStream = (event) => {
    event.preventDefault()
    this.pendingStreams.push(event.target)
  }

  flushStreams() {
    document.removeEventListener("turbo:before-stream-render", this.delayStream)
    this.pendingStreams.forEach(stream => stream.performAction())
    this.pendingStreams = []
  }

  disconnect() {
    document.removeEventListener("turbo:before-stream-render", this.delayStream)
  }
}
