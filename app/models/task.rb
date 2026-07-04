class Task < ApplicationRecord
    belongs_to :label, optional: true
    # Validations that title and due date are present when creating or updating a task
    validates :title, presence: true
    validates :due_on, presence: true
end
