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
end
