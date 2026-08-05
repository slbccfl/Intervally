class ViewsController < ApplicationController
  before_action :set_view, only: %i[ show edit update destroy ]

  # GET /views/1
  def show
    @tasks = @view.tasks.sorted_by_urgency
    @views = View.order(:position)
  end

  # GET / (root)
  def root
    redirect_to view_path(View.find_by!(name: View::UNASSIGNED_NAME))
  end

  # GET /views/new
  def new
    @view = View.new
  end

  # GET /views/1/edit
  def edit
  end

  # POST /views
  def create
    @view = View.new(view_params)

    respond_to do |format|
      if @view.save
        flash[:notice] = "View created."
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("view-list", partial: "views/view", locals: { view: @view, active_view: nil }),
            turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
          ]
        end
        format.html { redirect_to root_path, notice: "View created." }
      else
        flash[:alert] = "View could not be saved."
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /views/1
  def update
    if @view.unassigned?
      flash[:alert] = "The Unassigned view cannot be renamed."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
        end
        format.html { redirect_to root_path, alert: "The Unassigned view cannot be renamed." }
      end
      return # guard clause — stops here for Unassigned; do NOT let this fall through to @view.update below
    end

    if @view.update(view_params)
      respond_to do |format|
        flash[:notice] = "View updated."
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(@view),
            turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
          ]
        end
        format.html { redirect_to root_path, notice: "View updated." }
      end
    else
      flash[:alert] = "View could not be updated."
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /views/1
  def destroy
    if @view.unassigned?
      flash[:alert] = "The Unassigned view cannot be deleted."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
        end
        format.html { redirect_to root_path, alert: "The Unassigned view cannot be deleted." }
      end
      return # guard clause — stops here for Unassigned; do NOT let this fall through to @view.destroy! below
    end

    @view.destroy!

    respond_to do |format|
      flash[:notice] = "View deleted."
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@view),
          turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
        ]
      end
      format.html { redirect_to root_path, notice: "View deleted." }
    end
  end

  private
    def set_view
      @view = View.find(params.expect(:id))
    end

    def view_params
      params.expect(view: [ :name ])
    end
end