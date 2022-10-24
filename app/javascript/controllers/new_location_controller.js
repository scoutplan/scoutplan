import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("New location controller connected")
  }
}
