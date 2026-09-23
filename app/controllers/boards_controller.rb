class BoardsController < ApplicationController
  before_action :set_board, only: %i[ show edit update destroy move ]

  def root
    redirect_to board_path(Board.find_by!(name: Board::DEFAULT_NAME))
  end

  def show
    @boards = Board.order(:position)
    @views = @board.views.order(:position)
  end
  
  def move
    @board.insert_at(params[:position].to_i)
    head :ok
  end

  def new
    @board = Board.new
  end

  def edit
  end

  def create
    @board = Board.new(board_params)

    respond_to do |format|
      if @board.save
        flash[:notice] = "Board created."
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("board-list", partial: "boards/board", locals: { board: @board, current_board: nil }),
            turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
          ]
        end
        format.html { redirect_to root_path, notice: "Board created." }
      else
        flash[:alert] = "Board could not be saved."
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @board.default?
      flash[:alert] = "The Default board cannot be renamed."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
        end
        format.html { redirect_to root_path, alert: "The Default board cannot be renamed." }
      end
      return
    end

    if @board.update(board_params)
      respond_to do |format|
        flash[:notice] = "Board updated."
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(@board, partial: "boards/board", locals: { board: @board, current_board: nil }),
            turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
          ]
        end
        format.html { redirect_to root_path, notice: "Board updated." }
      end
    else
      flash[:alert] = "Board could not be updated."
      render :edit, status: :unprocessable_entity
    end
  end

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

  def board_params
    params.expect(board: [ :name ])
  end
end