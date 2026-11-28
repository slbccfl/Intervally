class DropLabels < ActiveRecord::Migration[8.1]
  def change
    # The foreign key and index go with the reference, so the labels table can then be dropped.
    remove_reference :tasks, :label, foreign_key: true, index: true

    drop_table :labels do |t|
      t.string :name
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
