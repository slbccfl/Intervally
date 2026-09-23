require "test_helper"

class BoardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @default = boards(:default)
    @board = boards(:secondary)
  end

  test "should get new" do
    get new_board_url
    assert_response :success
  end

  test "should create board" do
    assert_difference("Board.count") do
      post boards_url, params: { board: { name: "Another Board" } }
    end

    assert_redirected_to root_path
  end

  test "should create board with turbo stream and render a flash notice" do
    assert_difference("Board.count") do
      post boards_url,
        params: { board: { name: "Turbo Board" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :success
    assert_includes @response.body, "Board created."
  end

  test "should not create board with blank name" do
    assert_no_difference("Board.count") do
      post boards_url, params: { board: { name: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "should get edit" do
    get edit_board_url(@board)
    assert_response :success
  end

  test "should update board" do
    patch board_url(@board), params: { board: { name: "Renamed Board" } }
    assert_redirected_to root_path
    assert_equal "Renamed Board", @board.reload.name
  end

  test "should not update board with blank name" do
    patch board_url(@board), params: { board: { name: "" } }
    assert_response :unprocessable_entity
    assert_not_equal "", @board.reload.name
  end

  test "should not rename the default board" do
    patch board_url(@default), params: { board: { name: "Renamed Default" } }
    assert_equal "Default", @default.reload.name
  end

  test "should move board" do
    patch move_board_url(@board), params: { position: 1 }
    assert_response :success
    assert_equal 1, @board.reload.position
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