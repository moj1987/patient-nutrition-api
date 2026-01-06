# spec/requests/meal_food_items_spec.rb
require 'rails_helper'

RSpec.describe "MealFoodItems API", type: :request do
  it "adds valid food to meal" do
  # Setup
  patient = Patient.create!(name: "John", age: 45, room_number: "101", dietary_restrictions: [], status: "active")
  meal = patient.meals.create!(meal_type: "lunch", status: "served")
  food_item = FoodItem.create!(name: "Rice", calories: 130, protein: 3, carbs: 28, fat: 1, dietary_restrictions: [])

  # Test
  post "/meals/#{meal.id}/meal_food_items", params: { meal_food_item: { food_item_id: food_item.id, portion_size: 1.0 } }, as: :json

  # Assert
  expect(response).to have_http_status(:created)
  json = JSON.parse(response.body)
  expect(json['food_item_id']).to eq(food_item.id)
  expect(json['portion_size']).to eq("1.0")
end

  it "rejects food with dietary restrictions" do
  # Setup - patient with gluten restriction
  patient = Patient.create!(
    name: "Jane",
    age: 45,
    room_number: "101",
    dietary_restrictions: [ "gluten" ],
    status: "active"
  )

  # Setup - meal for this patient
  meal = patient.meals.create!(meal_type: "dinner", status: "scheduled")

  # Setup - bread with gluten restriction
  bread = FoodItem.create!(
    name: "Bread",
    calories: 80,
    protein: 2,
    carbs: 15,
    fat: 1,
    dietary_restrictions: [ "gluten" ]
  )

  # Test - try to add bread to gluten-restricted patient
  post "/meals/#{meal.id}/meal_food_items",
    params: { meal_food_item: { food_item_id: bread.id, portion_size: 0.5 } },
    as: :json

  # Assert - should fail with validation error
  expect(response).to have_http_status(:unprocessable_content)
  json = JSON.parse(response.body)
  expect(json['errors']['base']).to include("The patient cannot have this food due to dietry restrictions.")
end
end
