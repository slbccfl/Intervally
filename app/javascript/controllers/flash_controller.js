import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    // Automatically dismiss after 4 seconds
    if (this.element.classList.contains("notice") || this.element.classList.contains("info")) {
      this.timeout = setTimeout(() => {
        this.dismiss()
      }, 15000)
    }
  }
  
  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    // Fade out using Tailwind classes
    this.element.classList.add("opacity-0")
    
    // Remove the element from the DOM after the transition finishes
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }

  hide() {
    this.element.remove();
  }
}