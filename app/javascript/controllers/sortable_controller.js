import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      onEnd: (event) => {
        const viewId = event.item.dataset.viewId
        const newPosition = event.newIndex + 1

        fetch(`/views/${viewId}/move`, {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
          },
          body: JSON.stringify({ position: newPosition })
        })
        .then(response => {
        if (!response.ok) {
            alert("Could not save the new order. Reloading to show the current state.")
            window.location.reload()
        }
        })
        .catch(() => {
        alert("Could not reach the server. Reloading to show the current state.")
        window.location.reload()
        })
      }
    })
  }

  disconnect() {
    this.sortable.destroy()
  }
}