import { Controller } from "@hotwired/stimulus"

const MIN_LOADING_MS = 800

export default class extends Controller {
  static targets = ["button", "overlay"]

  submit() {
    this.buttonTarget.disabled = true
    this.overlayTarget.classList.remove("hidden")
    this.submittedAt = Date.now()
    this.pendingStreams = []
    this.flushScheduled = false

    document.addEventListener("turbo:before-stream-render", this.delayStream)
  }

  delayStream = (event) => {
    const elapsed = Date.now() - this.submittedAt
    const remaining = MIN_LOADING_MS - elapsed

    if (remaining > 0) {
      event.preventDefault()
      this.pendingStreams.push(event.target)

      if (!this.flushScheduled) {
        this.flushScheduled = true
        setTimeout(() => this.flushStreams(), remaining)
      }
    } else {
      document.removeEventListener("turbo:before-stream-render", this.delayStream)
    }
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
