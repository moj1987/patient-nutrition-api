class FoodItem < ApplicationRecord
  has_many :meal_food_items
  has_many :meals, through: :meal_food_items

  validates :name, presence: true, uniqueness: true
  validates :calories, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :carbs, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :protein, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :fat, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
