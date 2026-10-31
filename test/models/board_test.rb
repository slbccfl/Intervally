require "test_helper"

class BoardTest < ActiveSupport::TestCase
  test "requires a name" do
    board = Board.new(name: "")

    assert_not board.valid?
    assert_includes board.errors[:name], "can't be blank"
  end

  test "default? is true only for the Default board" do
    assert boards(:default).default?
    assert_not boards(:secondary).default?
  end

  test "Default board cannot be destroyed" do
    default = boards(:default)

    assert_no_difference("Board.count") do
      assert_not default.destroy
    end
    assert_includes default.errors.full_messages, "The Default board cannot be deleted"
  end

  test "destroying a board reassigns its views to the Default board" do
    board = Board.create!(name: "Temp Board")
    view = View.create!(name: "Temp View", board: board)

    board.destroy

    assert_equal boards(:default).id, view.reload.board_id
  end

  test "destroying a board does not delete its views" do
    board = Board.create!(name: "Temp Board")
    View.create!(name: "Temp View", board: board)

    assert_no_difference("View.count") do
      board.destroy
    end
  end
end
