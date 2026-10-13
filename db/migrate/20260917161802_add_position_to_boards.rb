class AddPositionToBoards < ActiveRecord::Migration[8.1]
  def change
    add_column :boards, :position, :integer, default: 1, null: false
    add_index :boards, :position
  end
end
