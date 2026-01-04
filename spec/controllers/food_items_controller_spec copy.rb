require 'rails_helper'

RSpec.describe "Food Items API", type: :request do
  describe "GET /food_items" do
    it "returns empty list without food items" do
      get "/food_items"

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(0)
    end

    it "returns all food items" do
      FoodItem.create(name: "Banana", calories: 145, protein: 1.3, carbs: 27, fat: 0.4)

      get "/food_items"

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(1)
      expect(json_response.first["name"]).to eq("Banana")
    end
  end

  describe "GET /food_items/:id" do
    it "returns 1 patient" do
      food = FoodItem.create(name: "Banana", calories: 145, protein: 1.3, carbs: 27, fat: 0.4)

      get "/food_items/#{food.id}"

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response["name"]).to eq("Banana")
      expect(json_response["protein"]).to eq("1.3")
    end
  end

  describe "POST /food_items" do
    it "creats a patient" do
      json_payload = '{ "food_item": {"name": "Banana", "calories" : 145, "protein" : 1.3, "carbs" : 27, "fat" : 0.4}}'
      headers = { "CONTENT_TYPE" => "application/json" }

      post "/food_items", params: json_payload, headers: headers

      expect(response).to have_http_status(:created)
    end

    it "does not creat a food item with invalid params" do
      json_payload = '{ "food_item": {"name": "Banana", "calories" : 145.3, "protein" : 1.3, "carbs" : 27, "fat" : 0.4}}'
      headers = { "CONTENT_TYPE" => "application/json" }

      post "/food_items", params: json_payload, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
