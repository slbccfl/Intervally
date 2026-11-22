class TasksController < ApplicationController
  before_action :set_task, only: %i[ edit update destroy toggle_status reassign_view ]

  # GET /tasks/new
  def new
    @task = Task.new(view_id: params[:view_id].presence || default_view_id)
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  def create
    @task = Task.new(task_params.merge(view_id: task_params[:view_id].presence || default_view_id))

    respond_to do |format|
      if @task.save
        flash[:notice] = "Task created."
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("task-list", partial: "tasks/task_list", locals: { tasks: @task.view.tasks.sorted_by_urgency }),
            turbo_stream.replace("task-list-#{@task.view.id}", partial: "tasks/task_list", locals: { tasks: @task.view.tasks.sorted_by_urgency, dom_id: "task-list-#{@task.view.id}" }),
            turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
          ]
        end
        format.html { redirect_to root_path, notice: "Task created." }
      else
        flash[:alert] = "Task could not be saved."
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1
  def update
    if @task.update(task_params)
      respond_to do |format|
        flash[:notice] = "Task updated."
        format.turbo_stream do
          streams = [
            turbo_stream.replace("task-list", partial: "tasks/task_list", locals: { tasks: @task.view.tasks.sorted_by_urgency }),
            turbo_stream.replace("task-list-#{@task.view.id}", partial: "tasks/task_list", locals: { tasks: @task.view.tasks.sorted_by_urgency, dom_id: "task-list-#{@task.view.id}" }),
            turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
          ]

          if @task.saved_change_to_view_id?
            old_view = View.find(@task.view_id_before_last_save)
            streams << turbo_stream.replace("task-list-#{old_view.id}", partial: "tasks/task_list", locals: { tasks: old_view.tasks.sorted_by_urgency, dom_id: "task-list-#{old_view.id}" })
          end

          render turbo_stream: streams
        end
        format.html { redirect_to root_path, notice: "Task updated." }
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
            turbo_stream.replace("task-list", partial: "tasks/task_list", locals: { tasks: @task.view.tasks.sorted_by_urgency }),
            turbo_stream.replace("task-list-#{@task.view.id}", partial: "tasks/task_list", locals: { tasks: @task.view.tasks.sorted_by_urgency, dom_id: "task-list-#{@task.view.id}" }),
            turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
          ]
        end
        format.html { redirect_to root_path, notice: flash[:notice] }
      end
    else
      flash[:alert] = "Task could not be updated."
      redirect_to root_path, alert: "Task could not be updated."
    end
  end

  # PATCH /tasks/1/reassign_view
  def reassign_view
    new_view = View.find(params.expect(:view_id))
    old_view = @task.view

    if @task.update(view: new_view)
      flash.now[:notice] = "Task moved to #{new_view.name}."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("task-list-#{old_view.id}", partial: "tasks/task_list", locals: { tasks: old_view.tasks.sorted_by_urgency, dom_id: "task-list-#{old_view.id}" }),
            turbo_stream.replace("task-list-#{new_view.id}", partial: "tasks/task_list", locals: { tasks: new_view.tasks.sorted_by_urgency, dom_id: "task-list-#{new_view.id}" }),
            turbo_stream.update("flash-container") { render_to_string(partial: "application/flashes") }
          ]
        end
      end
    else
      head :unprocessable_entity
    end
  end

  # DELETE /tasks/1
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

    def default_view_id
      View.find_by!(name: View::UNASSIGNED_NAME).id
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.expect(task: [ :title, :description, :completed, :priority, :label_id, :due_on, :cycle, :view_id ])
    end
end
