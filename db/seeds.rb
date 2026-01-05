# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

puts "Cleaning database..."
[ MealFoodItem, Meal, FoodItem, Patient ].each do |model|
  model.connection.execute("TRUNCATE TABLE #{model.table_name} RESTART IDENTITY CASCADE")
end
puts "Creating fresh data..."

patient1 = Patient.create!(
  name: "Jane Smith",
  age: 65,
  room_number: "201A",
  dietary_restrictions: [ "gluten", "lactose" ],
  status: "active"
)

puts "Creating food items..."

bread = FoodItem.create!(
  name: "Whole Wheat Bread",
  calories: 80,
  protein: 4,
  carbs: 15,
  fat: 1,
  dietary_restrictions: [ "gluten" ]
)

rice = FoodItem.create!(
  name: "Brown Rice",
  calories: 130,
  protein: 3,
  carbs: 28,
  fat: 1,
  dietary_restrictions: []
)

puts "Creating meals..."
lunch = Meal.create!(
  patient: patient1,
  meal_type: "lunch",
  status: "served"
)

dinner = Meal.create!(
  patient: patient1,
  meal_type: "dinner",
  status: "scheduled"
)

lunch.meal_food_items.create!(
  food_item: rice,
  portion_size: 1.0
)

# this will cause an error
# aborts save/create
create_result = dinner.meal_food_items.create!(
  food_item: bread,
  portion_size: 0.5
)

puts "did save? #{create_result.inspect}"

puts "#{dinner.errors.messages}"
puts "summary of the meal #{lunch.id} is #{lunch.nutrition_summary}"
puts "summary of the meal #{dinner.id} is #{dinner.nutrition_summary}"

puts "Finished!"
