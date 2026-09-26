require "test_helper"

class ViewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @view = views(:secondary)
    @unassigned = views(:unassigned)
  end

  test "should get new" do
    get new_view_url
    assert_response :success
  end

  test "should create view" do
    assert_difference("View.count") do
      post views_url, params: { view: { name: "Another View" } }
    end

    assert_redirected_to root_path
  end

  test "should create view with turbo stream and render a flash notice" do
    assert_difference("View.count") do
      post views_url,
        params: { view: { name: "Turbo View" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :success
    assert_includes @response.body, "View created."
  end

  test "should not create view with blank name" do
    assert_no_difference("View.count") do
      post views_url, params: { view: { name: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "should get edit" do
    get edit_view_url(@view)
    assert_response :success
  end

  test "should update view" do
    patch view_url(@view), params: { view: { name: "Renamed View" } }
    assert_redirected_to root_path
    assert_equal "Renamed View", @view.reload.name
  end

  test "should not update view with blank name" do
    patch view_url(@view), params: { view: { name: "" } }
    assert_response :unprocessable_entity
    assert_not_equal "", @view.reload.name
  end

  test "should destroy view and reassign its tasks to unassigned" do
    task = Task.create!(title: "Orphaned", due_on: Date.current, view: @view)

    assert_difference("View.count", -1) do
      delete view_url(@view)
    end

    assert_equal @unassigned.id, task.reload.view_id
  end

  test "should not destroy the unassigned view" do
    assert_no_difference("View.count") do
      delete view_url(@unassigned)
    end
  end

  test "should move view" do
    patch move_view_url(@view), params: { position: 1 }
    assert_response :success
    assert_equal 1, @view.reload.position
  end

  test "strong params should not permit position" do
    view_count_before = View.count

    post views_url, params: { view: { name: "Position Test", position: 99 } }

    assert_equal view_count_before + 1, View.find_by!(name: "Position Test").position
  end
  
  test "should create view on the given board" do
    board = Board.create!(name: "Weekly")

    assert_difference("View.count") do
      post views_url, params: { view: { name: "New Weekly View" }, board_id: board.id }
    end

    assert_equal board.id, View.find_by!(name: "New Weekly View").board_id
  end

  test "should create view with turbo stream and append to board grid" do
    board = Board.create!(name: "Weekly")

    assert_difference("View.count") do
      post views_url,
        params: { view: { name: "Grid View" }, board_id: board.id },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    view = View.find_by!(name: "Grid View")
    assert_includes @response.body, "view-column-#{view.id}"
  end
end
