import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, frame: String }

  navigate() {
    if (this.hasFrameValue) {
      Turbo.visit(this.urlValue, { frame: this.frameValue })
    } else {
      Turbo.visit(this.urlValue, { action: "advance" })
    }
  }
}