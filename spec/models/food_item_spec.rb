require 'rails_helper'

RSpec.describe FoodItem, type: :model do
  it "is valid with valid attributes" do
    food_item = FoodItem.new(name: "pizza", calories: 2500, protein: 150, carbs: 220, fat: 98)
    expect(food_item).to be_valid
  end

  it 'is not valid without a name' do
    food_item = FoodItem.new(calories: 2500, protein: 150, carbs: 220, fat: 98)
    expect(food_item).to_not be_valid
  end

  it 'is not valid if the name is not unique' do
    FoodItem.create(name: "pizza", calories: 2500, protein: 150, carbs: 220, fat: 98)
    food_item = FoodItem.new(name: "pizza", calories: 100, protein: 10, carbs: 20, fat: 5)
    expect(food_item).to_not be_valid
  end

  it 'is not valid without calories' do
    food_item = FoodItem.new(name: "burger", protein: 150, carbs: 220, fat: 98)
    expect(food_item).to_not be_valid
  end

  it 'is not valid with negative calories' do
    food_item = FoodItem.new(name: "burger", calories: -10, protein: 150, carbs: 220, fat: 98)
    expect(food_item).to_not be_valid
  end

  it 'is not valid with negative calories' do
    food_item = FoodItem.new(name: "burger", calories: -10, protein: 150, carbs: 220, fat: 98)
    expect(food_item).to_not be_valid
  end

  it 'is not valid with non-inteer calories' do
    food_item = FoodItem.new(name: "burger", calories: 10.2, protein: 150, carbs: 220, fat: 98)
    expect(food_item).to_not be_valid
  end

  it 'is not valid without protein' do
    food_item = FoodItem.new(name: "burger", calories: 2500, carbs: 220, fat: 98)
    expect(food_item).to_not be_valid
  end

  it 'is not valid with negative protein' do
    food_item = FoodItem.new(name: "burger", calories: 2500, protein: -10, carbs: 220, fat: 98)
    expect(food_item).to_not be_valid
  end

  it 'is not valid without carbs' do
    food_item = FoodItem.new(name: "burger", calories: 2500, protein: 150, fat: 98)
    expect(food_item).to_not be_valid
  end

  it 'is not valid with negative carbs' do
    food_item = FoodItem.new(name: "burger", calories: 2500, protein: 150, carbs: -10, fat: 98)
    expect(food_item).to_not be_valid
  end

  it 'is not valid without fat' do
    food_item = FoodItem.new(name: "burger", calories: 2500, protein: 150, carbs: 220)
    expect(food_item).to_not be_valid
  end

  it 'is not valid with negative fat' do
    food_item = FoodItem.new(name: "burger", calories: 2500, protein: 150, carbs: 220, fat: -10)
    expect(food_item).to_not be_valid
  end
end
