require 'rails_helper'

RSpec.describe "Meals API", type: :request do
  describe "GET /patients/:patient_id/meals" do
    it "returns empty list without meals for patient 1" do
      patient = Patient.create(name: "John Doe", age: 45, room_number: "29B", status: "active")

      get "/patients/#{patient.id}/meals"

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(0)
    end

    it "returns all the 1 meal for patient 1" do
      patient = Patient.create(name: "John Doe", age: 45, room_number: "29B", status: "active")
      patient.meals.create(meal_type: "lunch", status: "scheduled")

      other_patient = Patient.create(name: "John Doe II", age: 450, room_number: "29BB", status: "active")
      other_patient.meals.create(meal_type: "dinner", status: "served")

      get "/patients/#{patient.id}/meals"

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(1)
      expect(json_response.first["meal_type"]).to eq("lunch")
    end
  end

  describe "POST /patients/:patient_id/meals" do
    it "creats a patient" do
      patient = Patient.create(name: "John Doe", age: 45, room_number: "29B", status: "active")

      json_payload = '{ "meal": {"meal_type": "lunch", "status" : "served"}}'
      headers = { "CONTENT_TYPE" => "application/json" }

      post "/patients/#{patient.id}/meals", params: json_payload, headers: headers

      expect(response).to have_http_status(:created)
    end

    it "does not creat a food item with invalid params" do
      patient = Patient.create(name: "John Doe", age: 45, room_number: "29B", status: "active")

      json_payload = '{ "meal": {"meal_type": "", "status" : "served"}}'
      headers = { "CONTENT_TYPE" => "application/json" }

      post "/patients/#{patient.id}/meals", params: json_payload, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
