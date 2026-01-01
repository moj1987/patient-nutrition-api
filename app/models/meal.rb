class Meal < ApplicationRecord
  belongs_to :patient
  enum :status, { served: "served", scheduled: "scheduled", skipped: "skipped" }
  enum :meal_type, { breakfast: "breakfast", lunch: "lunch", dinner: "dinner", snack: "snack" }
end
