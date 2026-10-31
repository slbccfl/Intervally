require "test_helper"

class ViewTest < ActiveSupport::TestCase
  test "destroying a view reassigns its tasks to Unassigned" do
    view = View.create!(name: "Temp View", board: boards(:default))
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
    view = View.create!(name: "Temp View", board: boards(:default))
    task = Task.create!(title: "x", due_on: Date.today, view: view)

    assert_difference("Task.count", 0) do
      view.destroy
    end
  end

  test "reordering views in one board does not affect another board's positions" do
    other = Board.create!(name: "Other Board")
    first = View.create!(name: "First", board: other)
    second = View.create!(name: "Second", board: other)

    second.insert_at(1)

    assert_equal 1, second.reload.position
    assert_equal 2, first.reload.position
    assert_equal 1, views(:unassigned).reload.position
    assert_equal 2, views(:secondary).reload.position
  end
end
