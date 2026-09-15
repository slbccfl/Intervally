class BoardsController < ApplicationController
  before_action :set_board, only: :destroy

  def destroy
    if @board.default?
      flash[:alert] = "The Default board cannot be deleted."
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") } }
        format.html { redirect_to root_path, alert: "The Default board cannot be deleted." }
      end
      return
    end

    view_count = @board.views.count
    @board.destroy!
    flash[:notice] = view_count > 0 ? "Board deleted. #{view_count} view#{'s' unless view_count == 1} reassigned to Default." : "Board deleted."

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@board),
          turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
        ]
      end
      format.html { redirect_to root_path, notice: flash[:notice] }
    end
  end

  private

  def set_board
    @board = Board.find(params.expect(:id))
  end
end