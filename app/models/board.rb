class Board < ApplicationRecord
  DEFAULT_NAME = "Default"

  has_many :views

  validates :name, presence: true

  before_destroy :prevent_default_deletion

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
end