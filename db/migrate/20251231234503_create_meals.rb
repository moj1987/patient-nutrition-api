class CreateMeals < ActiveRecord::Migration[8.1]
  def change
    create_table :meals do |t|
      t.string :meal_type
      t.string :status

      t.timestamps
    end
  end
end
