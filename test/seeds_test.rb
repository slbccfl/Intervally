require "test_helper"

class SeedsTest < ActiveSupport::TestCase
  test "seeds create the Default board and Unassigned view on an empty database" do
    Task.delete_all
    View.delete_all
    Board.delete_all

    2.times { Rails.application.load_seed }

    assert_equal 1, Board.count
    default = Board.find_by!(name: Board::DEFAULT_NAME)
    assert_equal 1, View.count
    assert_equal default.id, View.find_by!(name: View::UNASSIGNED_NAME).board_id
  end

  test "seeds leave an Unassigned view that was moved to another board alone" do
    other = Board.create!(name: "Other Board")
    unassigned = views(:unassigned)
    unassigned.update!(board: other)

    Rails.application.load_seed

    assert_equal 1, View.where(name: View::UNASSIGNED_NAME).count
    assert_equal other.id, unassigned.reload.board_id
    assert_equal 1, Board.where(name: Board::DEFAULT_NAME).count
  end
end
