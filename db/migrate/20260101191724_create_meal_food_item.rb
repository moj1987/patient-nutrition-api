class CreateMealFoodItem < ActiveRecord::Migration[8.1]
  def change
    create_table :meal_food_items do |t|
      t.references :meal, null: false, foreign_key: true
      t.references :food_item, null: false, foreign_key: true
      t.decimal :portion_size

      t.timestamps
    end
  end
end
