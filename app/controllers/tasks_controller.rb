class TasksController < ApplicationController
  before_action :set_task, only: %i[ show edit update destroy ]

  # GET /tasks or /tasks.json
  def index
    # flash.alert = "Do not try to steal a majestic penguin!"
    # flash.notice = "You see a majestic penguin."
    @tasks = Task.all
  end

  # GET /tasks/1 or /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks or /tasks.json
  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        flash[:notice] = "Task created."
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("task-list", @task),
            turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
          ]
        end
        format.html { redirect_to @task, notice: "Task created." }
      else
        flash[:alert] = "Task could not be saved."
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1 or /tasks/1.json
  def update
      if @task.update(task_params)
        respond_to do |format| 
        flash[:notice] = "Task updated."
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
          ]
        end 
      end
    else
      flash[:alert] = "Task could not be updated."
      render :edit, status: :unprocessable_entity 
    end
  end

  # DELETE /tasks/1 or /tasks/1.json
  def destroy
    @task.destroy!

    respond_to do |format|
      flash[:notice] = "Task deleted."
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@task),
          turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
        ]
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.expect(task: [ :title, :description, :completed, :priority, :label_id, :due_on, :cycle ])
    end
end
