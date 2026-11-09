import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { taskId: Number }

  dragStart(event) {
    // Stop the column's view-drag handler from also firing for this drag
    event.stopPropagation()
    event.dataTransfer.setData("application/x-intervally-task-id", this.taskIdValue)
    event.dataTransfer.effectAllowed = "move"
  }
}