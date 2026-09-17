class Board < ApplicationRecord
  DEFAULT_NAME = "Default"

  acts_as_list
  
  has_many :views

  validates :name, presence: true

  before_destroy :prevent_default_deletion
  before_destroy :reassign_views_to_default

  def default?
    name == DEFAULT_NAME
  end

  private

  def prevent_default_deletion
    if default?
      errors.add(:base, "The Default board cannot be deleted")
      throw :abort
    end
  end
  
  def reassign_views_to_default
    views.update_all(board_id: Board.find_by!(name: DEFAULT_NAME).id)
  end
end