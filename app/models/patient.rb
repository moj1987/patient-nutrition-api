class Patient < ApplicationRecord
    has_many :meals
    enum :status, { active: 0, discharged: 1 }
end
