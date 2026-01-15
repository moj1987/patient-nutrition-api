require 'rails_helper'

RSpec.describe "Meals API", type: :request do
  let(:admin) { User.admin }
  let(:token) { JwtService.encode(admin.id) }
  let(:headers) { { "Authorization" => "Bearer #{token}", "CONTENT_TYPE" => "application/json" } }

  describe "GET /patients/:patient_id/meals" do
    it "returns empty list without meals for patient 1" do
      patient = Patient.create!(name: "John Doe", age: 45, room_number: "29B", status: "active")

      get "/patients/#{patient.id}/meals", headers: headers

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(0)
    end

    it "returns all the 1 meal for patient 1" do
      patient = Patient.create!(name: "John Doe", age: 45, room_number: "29B", status: "active")
      patient.meals.create!(meal_type: "lunch", status: "scheduled")

      other_patient = Patient.create!(name: "John Doe II", age: 450, room_number: "29BB", status: "active")
      other_patient.meals.create!(meal_type: "dinner", status: "served")

      get "/patients/#{patient.id}/meals", headers: headers

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(1)
      expect(json_response.first["meal_type"]).to eq("lunch")
    end
  end

  describe "POST /patients/:patient_id/meals" do
    let(:patient) { Patient.create!(name: "John Doe", age: 45, room_number: "29B", status: "active") }
    let(:valid_params) do
      {
        meal: {
          meal_type: "lunch",
          status: "scheduled"
        }
      }
    end

    it "creates a meal" do
      post "/patients/#{patient.id}/meals", params: valid_params.to_json, headers: headers

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response["meal_type"]).to eq("lunch")
    end

    it "does not create a meal with invalid params" do
      invalid_params = valid_params.merge(meal: { meal_type: "invalid" })

      expect {
        post "/patients/#{patient.id}/meals", params: invalid_params.to_json, headers: headers
      }.to raise_error(ArgumentError, /'invalid' is not a valid meal_type/)
    end
  end
end
