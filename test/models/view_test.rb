require "test_helper"

class ViewTest < ActiveSupport::TestCase
  test "destroying a view reassigns its tasks to Unassigned" do
    view = View.create!(name: "Temp View")
    task = Task.create!(title: "x", due_on: Date.today, view: view)

    view.destroy

    assert_equal "Unassigned", task.reload.view.name
  end

  test "Unassigned view cannot be destroyed" do
    unassigned = View.find_by(name: "Unassigned")

    assert_not unassigned.destroy
    assert_includes unassigned.errors.full_messages, "The Unassigned view cannot be deleted"
  end

  test "destroying a view does not delete its tasks" do
    view = View.create!(name: "Temp View")
    task = Task.create!(title: "x", due_on: Date.today, view: view)

    assert_difference("Task.count", 0) do
      view.destroy
    end
  end
end
