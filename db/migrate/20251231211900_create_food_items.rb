class CreateFoodItems < ActiveRecord::Migration[8.1]
  def change
    create_table :food_items do |t|
      t.string :name
      t.integer :calories
      t.decimal :protein
      t.decimal :carbs
      t.decimal :fat

      t.timestamps
    end
  end
end
