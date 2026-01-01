class Patient < ApplicationRecord
    has_many :meals
    enum :status, { active: 0, discharged: 1 }

    validates :name, presence: true
    validates :room_number, presence: true
    validates :status, presence: true
    validates :age, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
