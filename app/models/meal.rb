class Meal < ApplicationRecord
  belongs_to :patient
  has_many :meal_food_items
  has_many :food_items, through: :meal_food_items

  enum :status, { served: "served", scheduled: "scheduled", skipped: "skipped" }
  enum :meal_type, { breakfast: "breakfast", lunch: "lunch", dinner: "dinner", snack: "snack" }

  validates :meal_type, presence: true
  validates :status, presence: true
end
