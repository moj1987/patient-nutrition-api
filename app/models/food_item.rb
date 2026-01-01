class FoodItem < ApplicationRecord
  has_many :meal_food_items
  has_many :meals, through: :meal_food_items
end
