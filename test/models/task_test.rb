require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "should save task with title" do
    task = Task.new(title: "Test Task", description: "This is a test task.", due_on: Date.today, cycle: 1, view: views(:unassigned))
    assert task.save, "Failed to save the task with a title"
  end

  test "should not save task without title" do
    task = Task.new
    assert_not task.save, "Saved the task without a title"
  end

  test "completed tasks sort after incomplete tasks" do
    incomplete = Task.create!(title: "a", due_on: Date.today, view: views(:unassigned), completed: false, priority: 3)
    completed = Task.create!(title: "b", due_on: Date.today, view: views(:unassigned), completed: true, priority: 1)

    sorted = Task.sorted_by_urgency
    assert sorted.index(incomplete) < sorted.index(completed)
  end

  test "higher priority sorts before lower priority among incomplete tasks" do
    low_priority = Task.create!(title: "low", due_on: Date.today, view: views(:unassigned), priority: 5)
    high_priority = Task.create!(title: "high", due_on: Date.today, view: views(:unassigned), priority: 1)

    sorted = Task.sorted_by_urgency
    assert sorted.index(high_priority) < sorted.index(low_priority)
  end

  test "recurring task with soon due-ratio sorts before one further out" do
    soon = Task.create!(title: "soon", due_on: Date.tomorrow, cycle: 7, view: views(:unassigned), priority: 1)
    later = Task.create!(title: "later", due_on: Date.today + 6, cycle: 7, view: views(:unassigned), priority: 1)

    sorted = Task.sorted_by_urgency
    assert sorted.index(soon) < sorted.index(later)
  end

  test "one-time task (no cycle) sorts after any recurring task at same priority" do
    recurring = Task.create!(title: "rec", due_on: Date.tomorrow, cycle: 7, view: views(:unassigned), priority: 1)
    one_time = Task.create!(title: "once", due_on: Date.tomorrow, view: views(:unassigned), priority: 1)

    sorted = Task.sorted_by_urgency
    assert sorted.index(recurring) < sorted.index(one_time)
  end

  test "sorts tasks with completed last, then priority, then due ratio" do
    Task.delete_all

    lower_priority_task = Task.create!(title: "Lower priority", due_on: Date.current + 5.days, cycle: 2, priority: 1, view: views(:unassigned))
    higher_priority_task = Task.create!(title: "Higher priority", due_on: Date.current + 1.day, cycle: 2, priority: 2, view: views(:unassigned))
    completed_task = Task.create!(title: "Completed", due_on: Date.current, cycle: 2, priority: 1, completed: true, view: views(:unassigned))

    sorted_ids = [ lower_priority_task, higher_priority_task, completed_task ].sort_by(&:urgency_sort_key).pluck(:id)

    assert_equal [ lower_priority_task.id, higher_priority_task.id, completed_task.id ], sorted_ids
  end

  test "equal priority and equal due ratio sort by earliest due date" do
    # Both ratios are 1.0 (2 days / cycle 2, and 5 days / cycle 5), so only due_on separates them.
    later = Task.create!(title: "later", due_on: Date.current + 5.days, cycle: 5, view: views(:unassigned), priority: 1)
    earlier = Task.create!(title: "earlier", due_on: Date.current + 2.days, cycle: 2, view: views(:unassigned), priority: 1)

    sorted = Task.sorted_by_urgency
    assert sorted.index(earlier) < sorted.index(later)
  end
end
