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

    test "strong params should not permit position" do
    view_count_before = View.count

    post views_url, params: { view: { name: "Position Test", position: 99 } }

    assert_equal view_count_before + 1, View.find_by!(name: "Position Test").position
    end
end
