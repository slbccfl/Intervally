class TasksController < ApplicationController
  before_action :set_task, only: %i[ show edit update destroy ]

  # GET /tasks or /tasks.json
  def index
    # flash.alert = "Do not try to steal a majestic penguin!"
    # flash.notice = "You see a majestic penguin."
    # @tasks = Task.order(priority: :asc, due_on: :asc)
    @tasks = Task.all.sort_by do |task|
      days_until_due = (task.due_on - Date.current).to_i
      cycle_value = task.cycle.present? && task.cycle.to_i != 0 ? task.cycle.to_f : Float::INFINITY
      due_ratio = (days_until_due ? days_until_due : 0).to_f / cycle_value

      [task.priority.to_i, task.cycle.present? ? 0 : 1, due_ratio]
    end

    @tasks.each do |task|
      days_until_due = (task.due_on - Date.current).to_i
      due_ratio = (days_until_due ? days_until_due : 0).to_f / (task.cycle || 1).to_f
      Rails.logger.debug "Task id: #{task.id}, due_on: #{task.due_on}, cycle: #{task.cycle}, priority: #{task.priority}, days_until_due: #{days_until_due}, due_ratio: #{due_ratio}"
    end
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
            turbo_stream.replace("task_#{@task.id}", partial: "tasks/task", locals: { task: @task }),
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
