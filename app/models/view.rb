class View < ApplicationRecord
  # Handles the automatic drag-and-drop position sorting
  acts_as_list

  # Relates views to tasks. dependent: :destroy ensures that if a view 
  # is deleted, its tasks are cleaned up (or you can adjust this logic later)
  has_many :tasks, dependent: :destroy

  # A view must have a name to be valid
  validates :name, presence: true
end