class Meal < ApplicationRecord
  belongs_to :patient
  has_many :meal_food_items
  has_many :food_items, through: :meal_food_items

  enum :status, { served: "served", scheduled: "scheduled", skipped: "skipped" }
  enum :meal_type, { breakfast: "breakfast", lunch: "lunch", dinner: "dinner", snack: "snack" }

  validates :meal_type, presence: true
  validates :status, presence: true

  def nutrition_summary
    {
      calories: calculate_calories,
      protein: calculate_protein,
      carbs: calculate_carbs,
      fat: calculate_fat
    }
  end

  def calculate_calories
    total = 0
    meal_food_items.each do |mfi|
      total +=  mfi.food_item.calories * mfi.portion_size
    end
    total
  end

  def calculate_protein
    total = 0
    meal_food_items.each do |mfi|
      total +=  mfi.food_item.protein * mfi.portion_size
    end
    total
  end

  def calculate_carbs
    total = 0
    meal_food_items.each do |mfi|
      total +=  mfi.food_item.carbs * mfi.portion_size
    end
    total
  end

  def calculate_fat
    total = 0
    meal_food_items.each do |mfi|
      total +=  mfi.food_item.fat * mfi.portion_size
    end
    total
  end
end
