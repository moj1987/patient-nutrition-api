class AddDietaryRestrictionsToFoodItem < ActiveRecord::Migration[8.1]
  def change
    add_column :food_items, :dietary_restrictions, :jsonb
  end
end
