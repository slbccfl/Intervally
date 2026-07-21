class ChangeTaskViewIdToNullFalse < ActiveRecord::Migration[8.1]
  def change
    # Arguments: :table_name, :column_name, null_allowed?, default_value (optional)
    # Since all your existing tasks now have a view_id, this will succeed smoothly.
    change_column_null :tasks, :view_id, false
  end
end
