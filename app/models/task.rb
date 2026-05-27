class Task < ApplicationRecord
    belongs_to :label, optional: true
end
