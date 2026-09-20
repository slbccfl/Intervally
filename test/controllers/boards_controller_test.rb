require "test_helper"

class BoardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @default = boards(:default)
  end

  test "should destroy board and reassign its views to default" do
    board = Board.create!(name: "Temp Board")
    view = View.create!(name: "Temp View", board: board)

    assert_difference("Board.count", -1) do
      delete board_url(board)
    end

    assert_equal @default.id, view.reload.board_id
  end

  test "should show flash message with no reassignment clause when board has no views" do
    board = Board.create!(name: "Empty Board")

    delete board_url(board), headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_includes @response.body, "Board deleted."
    assert_not_includes @response.body, "reassigned"
    end

  test "should show flash message with reassigned view count" do
    board = Board.create!(name: "Temp Board")
    View.create!(name: "Temp View 1", board: board)
    View.create!(name: "Temp View 2", board: board)

    delete board_url(board), headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_includes @response.body, "Board deleted. 2 views reassigned to Default."
  end

  test "should not destroy the default board" do
    assert_no_difference("Board.count") do
      delete board_url(@default)
    end
  end

  test "root redirects to default board" do
    get root_path
    assert_redirected_to board_path(@default)
  end

  test "should show board with its views" do
    get board_path(@default)
    assert_response :success
    assert_includes @response.body, "Unassigned"
    assert_includes @response.body, "Secondary View"
  end
end