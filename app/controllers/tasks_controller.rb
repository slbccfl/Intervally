class TasksController < ApplicationController
  before_action :set_task, only: %i[ show edit update destroy toggle_status ]

  # GET /tasks or /tasks.json
  def index
    @tasks = Task.sorted_by_urgency
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
    @task = Task.new(task_params.merge(view_id: default_view_id))

    respond_to do |format|
      if @task.save
        flash[:notice] = "Task created."
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("task-list", partial: "tasks/task_list", locals: { tasks: Task.sorted_by_urgency }),
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
            turbo_stream.replace("task-list", partial: "tasks/task_list", locals: { tasks: Task.sorted_by_urgency }),
            turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
          ]
        end
        format.html { redirect_to @task, notice: "Task updated." }
      end
    else
      flash[:alert] = "Task could not be updated."
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle_status
    completed = params.key?(:completed) ? params[:completed] == "true" : true
    attributes = { completed: completed }

    if completed && @task.cycle.present? && @task.cycle.to_i.positive?
      attributes = {
        completed: false,
        due_on: Date.current + @task.cycle.to_i.days
      }
    end

    if @task.update(attributes)
      respond_to do |format|
        flash[:notice] = if completed && @task.cycle.present? && @task.cycle.to_i.positive?
          "Task rescheduled."
        else
          completed ? "Task completed." : "Task marked incomplete."
        end
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("task-list", partial: "tasks/task_list", locals: { tasks: Task.sorted_by_urgency }),
            turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
          ]
        end
        format.html { redirect_to tasks_url, notice: flash[:notice] }
      end
    else
      flash[:alert] = "Task could not be updated."
      redirect_to tasks_url, alert: "Task could not be updated."
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

    # def task_sort_key(task)
    #   days_until_due = (task.due_on - Date.current).to_i
    #   cycle_value = task.cycle.present? && task.cycle.to_i.positive? ? task.cycle.to_f : Float::INFINITY
    #   due_ratio = cycle_value == Float::INFINITY ? Float::INFINITY : ((days_until_due ? days_until_due : 0).to_f / cycle_value)

    #   [task.completed ? 1 : 0, task.priority.to_i, due_ratio, task.due_on]
    # end

    def default_view_id
      View.find_by!(name: View::UNASSIGNED_NAME).id
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.expect(task: [ :title, :description, :completed, :priority, :label_id, :due_on, :cycle ])
    end
end
