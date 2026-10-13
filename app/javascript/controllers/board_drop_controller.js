import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { viewId: Number, boardId: Number }

  dragStart(event) {
    event.dataTransfer.setData("application/x-intervally-view-id", this.viewIdValue)
    event.dataTransfer.effectAllowed = "move"
  }

  dragOver(event) {
    event.preventDefault()
    if (event.dataTransfer.types.includes("application/x-intervally-view-id")) {
      if (!this.previousBg) {
        this.previousBg = ["bg-gray-200", "bg-blue-200"].find(cls => this.element.classList.contains(cls))
        if (this.previousBg) this.element.classList.remove(this.previousBg)
        this.element.classList.add("bg-blue-400")
      }
    }
  }

  dragLeave(event) {
    this.element.classList.remove("bg-blue-400")
    if (this.previousBg) this.element.classList.add(this.previousBg)
    this.previousBg = undefined
  }

  drop(event) {
    event.preventDefault()
    this.element.classList.remove("bg-blue-400")
    if (this.previousBg) this.element.classList.add(this.previousBg)
    this.previousBg = undefined

    if (!event.dataTransfer.types.includes("application/x-intervally-view-id")) return

    const viewId = event.dataTransfer.getData("application/x-intervally-view-id")

    fetch(`/views/${viewId}/reassign_board`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify({ board_id: this.boardIdValue })
    })
      .then(response => response.ok ? response.text() : Promise.reject())
      .then(html => Turbo.renderStreamMessage(html))
      .catch(() => {
        alert("Could not move the view. Reloading to show the current state.")
        window.location.reload()
      })
  }
}