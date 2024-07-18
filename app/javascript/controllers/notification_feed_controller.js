import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notification-feed"
export default class extends Controller {
  static targets = ["item"]
  connect() {
  }

  itemTargetConnected(element) {
    element.classList.add('animate')
  }
}
