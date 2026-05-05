class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.date :due_on
      t.integer :cycle

      t.timestamps
    end
  end
end
