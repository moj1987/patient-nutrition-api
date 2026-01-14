require 'rails_helper'

RSpec.describe "Patients API", type: :request do
  let(:admin) { User.admin }
  let(:token) { JwtService.encode(admin.id) }
  let(:headers) { { "Authorization" => "Bearer #{token}", "CONTENT_TYPE" => "application/json" } }

  describe "GET /patients" do
    context "with authentication" do
      it "returns empty list without patients" do
        get "/patients", headers: headers

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(0)
      end

      it "returns all patients" do
        patient1 = Patient.create!(name: "John Doe", age: 45, room_number: "29B", status: "active")
        patient2 = Patient.create!(name: "Jane Smith", age: 30, room_number: "30A", status: "active")

        get "/patients", headers: headers

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(2)
        patient_ids = json_response.map { |p| p["id"] }
        expect(patient_ids).to include(patient1.id, patient2.id)
      end
    end

    context "without authentication" do
      it "returns unauthorized error" do
        get "/patients"

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Authentication required")
      end
    end
  end

  describe "GET /patients/:id" do
    let(:patient) { Patient.create!(name: "John Doe", age: 87, room_number: "209B", status: "active") }

    context "with authentication" do
      it "returns patient" do
        get "/patients/#{patient.id}", headers: headers

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["name"]).to eq("John Doe")
        expect(json_response["age"]).to eq(87)
      end

      it "returns not found for non-existent patient" do
        get "/patients/99999", headers: headers

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Patient not found")
      end
    end

    context "without authentication" do
      it "returns unauthorized error" do
        get "/patients/#{patient.id}"

        expect(response).to have_http_status(:unauthorized)
      end
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

    context "with authentication" do
      it "creates a patient" do
        post "/patients", params: valid_params.to_json, headers: headers

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["name"]).to eq("John Doe")
      end

      it "returns unprocessable content for invalid params" do
        invalid_params = valid_params.merge(patient: { name: "John Doe", age: "invalid", room_number: "209B", status: "active" })

        post "/patients", params: invalid_params.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "without authentication" do
      it "returns unauthorized error" do
        post "/patients", params: valid_params.to_json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /patients/:id" do
    let(:patient) { Patient.create!(name: "John Doe", age: 87, room_number: "209B", status: "active") }
    let(:update_params) { { patient: { name: "John Updated" } } }

    context "with authentication" do
      it "updates patient" do
        patch "/patients/#{patient.id}", params: update_params.to_json, headers: headers

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["name"]).to eq("John Updated")
      end

      it "returns not found for non-existent patient" do
        patch "/patients/99999", params: update_params.to_json, headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context "without authentication" do
      it "returns unauthorized error" do
        patch "/patients/#{patient.id}", params: update_params.to_json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /patients/:id" do
    let(:patient) { Patient.create!(name: "John Doe", age: 87, room_number: "209B", status: "active") }

    context "with authentication" do
      it "deletes patient" do
        expect {
          delete "/patients/#{patient.id}", headers: headers
        }.to change(Patient, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end

      it "returns not found for non-existent patient" do
        delete "/patients/99999", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context "without authentication" do
      it "returns unauthorized error" do
        delete "/patients/#{patient.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
