class Label < ApplicationRecord
    has_many :tasks, dependent: :destroy
    validates :name, presence: { message: " is a required field" }
end
