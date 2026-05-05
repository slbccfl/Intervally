class AddCompletedAndPriorityToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :completed, :boolean, default: false, null: false
    add_column :tasks, :priority, :integer, default: 1, null: false
  end
end
