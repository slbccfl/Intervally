class CreateViews < ActiveRecord::Migration[8.1]
  def change
    create_table :views do |t|
      t.string :name, null: false
      t.integer :position, null: false, default: 1

      t.timestamps
    end

    add_index :views, :position
  end
end
