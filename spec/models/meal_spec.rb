require 'rails_helper'

RSpec.describe Meal, type: :model do
  it "is valid with valid attributes" do
    patient = Patient.new(name: "Jane Doe", age: 80, room_number: "202A", status: 'active')
    meal = Meal.new(patient: patient, meal_type: "lunch", status: "served")
    expect(meal).to be_valid
  end

  it "is not valid without a meal_type" do
    patient = Patient.new(name: "Jane Doe", age: 80, room_number: "202A", status: 'active')
    meal = Meal.new(patient: patient, status: "served")
    expect(meal).to_not be_valid
  end

  it "is not valid without a status" do
    patient = Patient.new(name: "Jane Doe", age: 80, room_number: "202A", status: 'active')
    meal = Meal.new(patient: patient, meal_type: "lunch")
    expect(meal).to_not be_valid
  end

  it "is not valid without a patient" do
    meal = Meal.new(meal_type: "lunch", status: "served")
    expect(meal).to_not be_valid
  end

  it "raises an error with an invalid meal_type" do
    patient = Patient.new(name: "Jane Doe", age: 80, room_number: "202A", status: 'active')
    expect {
      Meal.new(patient: patient, meal_type: "invalid_meal_type", status: "served")
    }.to raise_error(ArgumentError)
  end

  it "raises an error with an invalid status" do
    patient = Patient.new(name: "Jane Doe", age: 80, room_number: "202A", status: 'active')
    expect {
      Meal.new(patient: patient, meal_type: "lunch", status: "invalid_status")
    }.to raise_error(ArgumentError)
  end

  it "calculates 0 calories for a meal without food items" do
    patient = Patient.new(name: "Jane Doe", age: 80, room_number: "202A", status: 'active')
    meal = Meal.new(patient: patient, meal_type: "lunch", status: "served")
    expect(meal.calculate_calories).to eq(0)
  end
  it "calculates calories for a meal with rice and chicken" do
    chicken = FoodItem.create!(name: "Chicken", calories: 100, protein: 20, carbs: 0, fat: 2)
    rice = FoodItem.create!(name: "Rice", calories: 130, protein: 3, carbs: 28, fat: 1)

    patient = Patient.create!(name: "Jane Doe", age: 80, room_number: "202A", status: 'active')
    meal = Meal.create!(patient: patient, meal_type: "lunch", status: "served")


    meal.meal_food_items.create!(food_item: chicken, portion_size: 1.0)
    meal.meal_food_items.create!(food_item: rice, portion_size: 0.5)

    expect(meal.calculate_calories).to eq(165)
  end

  it "calculates nutrition summary" do
    chicken = FoodItem.create!(name: "Chicken", calories: 100, protein: 20, carbs: 0, fat: 2)
    rice = FoodItem.create!(name: "Rice", calories: 130, protein: 3, carbs: 28, fat: 1)
    patient = Patient.create!(name: "Jane Doe", age: 80, room_number: "202A", status: 'active')
    meal = Meal.create!(patient: patient, meal_type: "lunch", status: "served")

    meal.meal_food_items.create!(food_item: chicken, portion_size: 1.0)
    meal.meal_food_items.create!(food_item: rice, portion_size: 0.5)

   expect(meal.nutrition_summary[:calories]).to eq(165)
   expect(meal.nutrition_summary[:protein]).to eq(21.5)
   expect(meal.nutrition_summary[:carbs]).to eq(14)
   expect(meal.nutrition_summary[:fat]).to eq(2.5)
  end
end
