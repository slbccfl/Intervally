class CreateBoardsAndAssignViews < ActiveRecord::Migration[8.1]
  def up
    create_table :boards do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_reference :views, :board, foreign_key: true

    unless Board.exists?(name: Board::DEFAULT_NAME)
      Board.create!(name: Board::DEFAULT_NAME)
    end

    default_board = Board.find_by!(name: Board::DEFAULT_NAME)
    View.where(board_id: nil).update_all(board_id: default_board.id)

    change_column_null :views, :board_id, false
  end

  def down
    remove_column :views, :board_id
    drop_table :boards
  end
end