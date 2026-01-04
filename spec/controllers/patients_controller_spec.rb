require 'rails_helper'

RSpec.describe "Patients API", type: :request do
  describe "GET /patients" do
    it "returns empty list without patients" do
      get patients_index_url

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(0)
    end

    it "returns all patients" do
      Patient.create(name: "John Doe", age: 45, room_number: "29B", status: "active")

      get patients_index_url

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(1)
      expect(json_response.first["name"]).to eq("John Doe")
    end
  end

  describe "GET /patients/:id" do
    it "returns 1 patient" do
      patient = Patient.create(name: "John Doe", age: 87, room_number: "209B", status: "active")

      get "/patients/#{patient.id}"

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response["name"]).to eq("John Doe")
      expect(json_response["age"]).to eq(87)
    end
  end

  describe "POST /patients" do
    it "creats a patient" do
      json_payload = '{ "patient": {"name": "John Doe", "age": 87, "room_number": "209B", "status": "active"}}'
      headers = { "CONTENT_TYPE" => "application/json" }

      post "/patients", params: json_payload, headers: headers

      expect(response).to have_http_status(:created)
    end

    it "does not creat a patient with invalid params" do
      json_payload = '{ "patient": {"name": "John Doe", "age": 87.9, "room_number": "209B", "status": "active"}}'
      headers = { "CONTENT_TYPE" => "application/json" }

      post "/patients", params: json_payload, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /patients" do
    it "updates the patient" do
      patient = Patient.create(name: "John Doe", age: 45, room_number: "29B", status: "active")
      json_payload = '{ "patient": {"name": "NEW name", "age": 87, "room_number": "209B", "status": "active"}}'
      headers = { "CONTENT_TYPE" => "application/json" }

      patch "/patients/#{patient.id}", params: json_payload, headers: headers

      expect(response).to have_http_status(:ok)
    end

    it "does not update the patient with invalid params" do
      patient = Patient.create(name: "John Doe", age: 45, room_number: "29B", status: "active")
      json_payload = '{ "patient": {"name": 45, "age": 87.5, "room_number": "209B", "status": "active"}}'
      headers = { "CONTENT_TYPE" => "application/json" }

      patch "/patients/#{patient.id}", params: json_payload, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /patients" do
    it "deletes the patient" do
      patient = Patient.create(name: "John Doe", age: 45, room_number: "29B", status: "active")

      delete "/patients/#{patient.id}"

      expect(response).to have_http_status(:no_content)
    end

    it "does not delete none-exisiting patient" do
      delete "/patients/1"

      expect(response).to have_http_status(:not_found)
    end
  end
end
