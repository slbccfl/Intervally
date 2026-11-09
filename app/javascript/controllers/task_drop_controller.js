import { Controller } from "@hotwired/stimulus"

const TASK_TYPE = "application/x-intervally-task-id"
const HIGHLIGHT = ["ring-2", "ring-inset", "ring-blue-400", "rounded"]

export default class extends Controller {
  static values = { viewId: Number }

  dragOver(event) {
    if (!event.dataTransfer.types.includes(TASK_TYPE)) return
    event.preventDefault()
    this.element.classList.add(...HIGHLIGHT)
  }

  dragLeave(event) {
    // dragleave also fires when the pointer moves onto a child element; ignore that
    if (this.element.contains(event.relatedTarget)) return
    this.clearHighlight()
  }

  drop(event) {
    if (!event.dataTransfer.types.includes(TASK_TYPE)) return
    event.preventDefault()
    this.clearHighlight()

    const taskId = event.dataTransfer.getData(TASK_TYPE)

    // Dropped back onto its own column: nothing to do
    if (this.element.querySelector(`#task_${taskId}`)) return

    fetch(`/tasks/${taskId}/reassign_view`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify({ view_id: this.viewIdValue })
    })
      .then(response => response.ok ? response.text() : Promise.reject())
      .then(html => Turbo.renderStreamMessage(html))
      .catch(() => {
        alert("Could not move the task. Reloading to show the current state.")
        window.location.reload()
      })
  }

  clearHighlight() {
    this.element.classList.remove(...HIGHLIGHT)
  }
}
