require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @task = tasks(:one)
  end

  test "should get index" do
    get tasks_url
    assert_response :success
  end

  test "should get new" do
    get new_task_url
    assert_response :success
  end

  test "index orders tasks by due ratio and puts null-cycle tasks last" do
    Task.delete_all

    earlier_task = Task.create!(title: "Earlier", due_on: Date.current + 2.days, cycle: 2, priority: 1)
    later_task = Task.create!(title: "Later", due_on: Date.current + 5.days, cycle: 5, priority: 1)
    no_cycle_task = Task.create!(title: "No Cycle", due_on: Date.current + 10.days, cycle: nil, priority: 1)

    get tasks_url

    assert_response :success
    assert_equal [earlier_task.id, later_task.id, no_cycle_task.id], assigns(:tasks).pluck(:id)
  end

  test "index prioritizes tasks by priority before due ratio" do
    Task.delete_all

    lower_priority_task = Task.create!(title: "Lower priority", due_on: Date.current + 5.days, cycle: 2, priority: 1)
    higher_priority_task = Task.create!(title: "Higher priority", due_on: Date.current + 1.day, cycle: 2, priority: 2)

    get tasks_url

    assert_response :success
    assert_equal [lower_priority_task.id, higher_priority_task.id], assigns(:tasks).pluck(:id)
  end

  test "index puts completed tasks at the end" do
    Task.delete_all

    incomplete_task = Task.create!(title: "Incomplete", due_on: Date.current + 1.day, cycle: 2, priority: 1)
    completed_task = Task.create!(title: "Completed", due_on: Date.current, cycle: 2, priority: 1, completed: true)

    get tasks_url

    assert_response :success
    assert_equal [incomplete_task.id, completed_task.id], assigns(:tasks).pluck(:id)
  end

  test "flash messages should allow pointer interactions" do
    get tasks_url
    assert_response :success
    assert_includes @response.body, "pointer-events-auto"
  end

  test "should create task" do
    assert_difference("Task.count") do
      post tasks_url, params: { task: { cycle: @task.cycle, description: @task.description, due_on: @task.due_on, title: @task.title } }
    end

    assert_redirected_to task_url(Task.last)
  end

  test "should create task with turbo stream and render a flash notice" do
    assert_difference("Task.count") do
      post tasks_url,
        params: { task: { cycle: @task.cycle, description: @task.description, due_on: @task.due_on, title: @task.title } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :success
    assert_includes @response.body, "Task created."
  end

  test "should show task" do
    get task_url(@task)
    assert_response :success
  end

  test "should get edit" do
    get edit_task_url(@task)
    assert_response :success
  end

  test "should update task" do
    patch task_url(@task), params: { task: { cycle: @task.cycle, description: @task.description, due_on: @task.due_on, title: @task.title } }
    assert_redirected_to task_url(@task)
  end

  test "should toggle task status to completed" do
    @task.update!(completed: false)

    patch toggle_status_task_url(@task)

    assert_redirected_to tasks_url
    assert @task.reload.completed
  end
end
