class Meal < ApplicationRecord
  belongs_to :patient
  has_many :meal_food_items, before_add: :dietary_restrictions_not_violated
  has_many :food_items, through: :meal_food_items

  enum :status, { served: "served", scheduled: "scheduled", skipped: "skipped" }
  enum :meal_type, { breakfast: "breakfast", lunch: "lunch", dinner: "dinner", snack: "snack" }

  validates :meal_type, presence: true
  validates :status, presence: true

  def nutrition_summary
    {
      calories: calculate_calories.to_f,
      protein: calculate_protein.to_f,
      carbs: calculate_carbs.to_f,
      fat: calculate_fat.to_f
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
  def get_restrictions
    self.patient.dietary_restrictions || []
  end
  def does_violate_dietry_restriction
    restrictions = []
    self.meal_food_items.each do |mfi|
      food_item_restrictions = mfi.food_item.dietary_restrictions || []
      common_restrictions = food_item_restrictions & get_restrictions
      restrictions.concat(common_restrictions)
    end
    restrictions.any?
  end

  # TODO remove raise as it'll throw 500
  # it will not now as throw returns
  def dietary_restrictions_not_violated(added_item)
    food_item = added_item.food_item
    food_restrictions = food_item.dietary_restrictions || []
    patient_restrictions = patient.dietary_restrictions || []

    if (food_restrictions & patient_restrictions).any?
      errors.add(:base, "The patient cannot have this food due to dietry restrictions.")
      # this returns at throw and will not get to raise!!!
      # keeping raise for learning purposes
      throw(:abort)
      raise "The patient cannot have this food due to dietry restrictions."
    end
  end
end
