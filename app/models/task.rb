class Task < ApplicationRecord
    # Links the task back to its parent view
    belongs_to :view
    belongs_to :label, optional: true
    # Validations that title and due date are present when creating or updating a task
    validates :title, presence: true
    validates :due_on, presence: true
    validates :priority, presence: true, inclusion: { in: 1..5 }
    validates :cycle, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

    scope :sorted_by_urgency, -> { sort_by(&:urgency_sort_key) }

    def urgency_sort_key
        days_until_due = due_on ? (due_on - Date.current).to_i : 0
        cycle_value = cycle.present? && cycle.to_i.positive? ? cycle.to_f : Float::INFINITY
        due_ratio = cycle_value == Float::INFINITY ? Float::INFINITY : (days_until_due / cycle_value)

        [completed? ? 1 : 0, priority.to_i, due_ratio, due_on]
    end
end
