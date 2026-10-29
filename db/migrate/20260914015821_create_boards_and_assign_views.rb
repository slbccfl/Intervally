class CreateBoardsAndAssignViews < ActiveRecord::Migration[8.1]
  class MigrationBoard < ActiveRecord::Base
    self.table_name = "boards"
  end

  class MigrationView < ActiveRecord::Base
    self.table_name = "views"
  end

  def up
    create_table :boards do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_reference :views, :board, foreign_key: true

    default_board = MigrationBoard.find_or_create_by!(name: "Default")
    MigrationView.where(board_id: nil).update_all(board_id: default_board.id)

    change_column_null :views, :board_id, false
  end

  def down
    remove_column :views, :board_id
    drop_table :boards
  end
end
