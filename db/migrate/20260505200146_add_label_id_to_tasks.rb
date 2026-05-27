class AddLabelIdToTasks < ActiveRecord::Migration[8.1]
  def change
    add_reference :tasks, :label, foreign_key: true
  end
end
