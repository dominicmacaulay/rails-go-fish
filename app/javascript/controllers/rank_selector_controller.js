import { Controller } from "@hotwired/stimulus"
// Connects to data-controller="rank-selector"
export default class extends Controller {
  connect() {
    this.selectedRank = null
  }
  static targets = ["input", "button"]
  select(event) {
    event.preventDefault()
    const button = event.currentTarget
    this.selectedRank = button.dataset.rank
    this.inputTarget.value = this.selectedRank
    this.buttonTargets.forEach(btn => btn.classList.remove("btn--active"))
    button.classList.add("btn--active")
  }
}
