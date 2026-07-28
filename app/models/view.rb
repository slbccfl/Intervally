class View < ApplicationRecord
  # The name of the unassigned view
  UNASSIGNED_NAME = "Unassigned"
  # Handles the automatic drag-and-drop position sorting
  acts_as_list

  # Relates views to tasks. 
  has_many :tasks

  # A view must have a name to be valid
  validates :name, presence: true

  before_destroy :prevent_unassigned_deletion
  before_destroy :reassign_tasks_to_unassigned

  private

  def prevent_unassigned_deletion
    if name == UNASSIGNED_NAME
      errors.add(:base, "The Unassigned view cannot be deleted")
      throw :abort
    end
  end

  def reassign_tasks_to_unassigned
    tasks.update_all(view_id: View.find_by!(name: UNASSIGNED_NAME).id)
  end
end
