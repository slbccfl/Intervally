class SeedUnassignedView < ActiveRecord::Migration[8.1]
  def up
    return if View.exists?(name: View::UNASSIGNED_NAME)
    View.create!(name: View::UNASSIGNED_NAME)
  end

  def down
    View.find_by(name: View::UNASSIGNED_NAME)&.destroy
  end
end
