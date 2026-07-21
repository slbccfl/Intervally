class AddViewToTasks < ActiveRecord::Migration[8.1]
  def change
    add_reference :tasks, :view, null: true, foreign_key: true
  end
end
