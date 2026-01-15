require 'rails_helper'

RSpec.describe Authentication, type: :controller do
  controller(ApplicationController) do
    include Authentication

    def index
      render json: { message: "Authenticated endpoint" }
    end
  end

  let(:admin) { User.admin }
  let(:token) { JwtService.encode(admin.id) }

  describe "authentication" do
    context "with valid token" do
      before do
        request.headers['Authorization'] = "Bearer #{token}"
      end

      it "sets current_user" do
        get :index

        expect(assigns(:current_user)).to eq(admin)
        expect(response).to have_http_status(:ok)
      end

      it "allows access to protected endpoint" do
        get :index

        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Authenticated endpoint")
      end
    end

    context "without token" do
      it "returns unauthorized error" do
        get :index

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Authentication required")
      end
    end

    context "with invalid token" do
      before do
        request.headers['Authorization'] = "Bearer invalid_token"
      end

      it "returns unauthorized error" do
        get :index

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Invalid token")
      end
    end

    context "with expired token" do
      let(:expired_token) { JwtService.encode(admin.id, -1.hour.from_now) }

      before do
        request.headers['Authorization'] = "Bearer #{expired_token}"
      end

      it "returns unauthorized error" do
        get :index

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Token expired")
      end
    end

    context "with malformed Authorization header" do
      before do
        request.headers['Authorization'] = "InvalidFormat #{token}"
      end

      it "returns unauthorized error" do
        get :index

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Authentication required")
      end
    end
  end

  describe "current_user helper" do
    let(:admin) { User.admin }
    let(:token) { JwtService.encode(admin.id) }

    before do
      request.headers['Authorization'] = "Bearer #{token}"
      get :index
    end

    it "provides access to current_user" do
      expect(controller.send(:current_user)).to eq(admin)
    end
  end
end
