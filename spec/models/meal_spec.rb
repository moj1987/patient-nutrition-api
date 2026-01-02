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
end
