require 'rails_helper'

RSpec.describe "Patients API", type: :request do
  let(:admin) { User.admin }
  let(:token) { JwtService.encode(admin.id) }
  let(:headers) { { "Authorization" => "Bearer #{token}", "CONTENT_TYPE" => "application/json" } }

  describe "GET /patients" do
    it "returns empty list without patients" do
      get "/patients", headers: headers

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(0)
    end

    it "returns all patients" do
      Patient.create!(name: "John Doe", age: 45, room_number: "29B", status: "active")

      get "/patients", headers: headers

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(1)
      expect(json_response.first["name"]).to eq("John Doe")
    end
  end

  describe "GET /patients/:id" do
    let(:patient) { Patient.create!(name: "John Doe", age: 87, room_number: "209B", status: "active") }

    it "returns 1 patient" do
      get "/patients/#{patient.id}", headers: headers

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response["name"]).to eq("John Doe")
      expect(json_response["age"]).to eq(87)
    end
  end

  describe "POST /patients" do
    let(:valid_params) do
      {
        patient: {
          name: "John Doe",
          age: 87,
          room_number: "209B",
          status: "active"
        }
      }
    end

    it "creates a patient" do
      post "/patients", params: valid_params.to_json, headers: headers

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response["name"]).to eq("John Doe")
    end

    it "does not create a patient with invalid params" do
      invalid_params = valid_params.merge(patient: { name: "John Doe", age: "invalid", room_number: "209B", status: "active" })

      post "/patients", params: invalid_params.to_json, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /patients" do
    let(:patient) { Patient.create!(name: "John Doe", age: 87, room_number: "209B", status: "active") }
    let(:update_params) { { patient: { name: "John Updated" } } }

    it "updates the patient" do
      patch "/patients/#{patient.id}", params: update_params.to_json, headers: headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["name"]).to eq("John Updated")
    end

    it "does not update the patient with invalid params" do
      invalid_params = { patient: { age: "invalid" } }

      patch "/patients/#{patient.id}", params: invalid_params.to_json, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /patients" do
    let(:patient) { Patient.create!(name: "John Doe", age: 87, room_number: "209B", status: "active") }

    it "deletes the patient" do
      delete "/patients/#{patient.id}", headers: headers

      expect(response).to have_http_status(:no_content)
    end

    it "does not delete none-existing patient" do
      delete "/patients/99999", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end
end
