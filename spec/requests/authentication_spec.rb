require 'rails_helper'

RSpec.describe "Authentication API", type: :request do
  describe "POST /auth/request-otp" do
    context "with valid email" do
      let(:email) { "test@example.com" }

      before do
        allow(OtpService).to receive(:generate).with(email).and_return("123456")
        allow(OtpMailer).to receive_message_chain(:send_otp, :deliver_now)
      end

      it "returns success message" do
        post "/auth/request-otp", params: { email: email }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("OTP sent successfully")
      end

      it "generates and stores OTP" do
        expect(OtpService).to receive(:generate).with(email).and_return("123456")

        post "/auth/request-otp", params: { email: email }

        expect(response).to have_http_status(:ok)
      end

      it "sends OTP email" do
        expect(OtpMailer).to receive(:send_otp).with(email, "123456")

        post "/auth/request-otp", params: { email: email }

        expect(response).to have_http_status(:ok)
      end

      it "returns OTP in development environment" do
        allow(Rails.env).to receive(:development?).and_return(true)

        post "/auth/request-otp", params: { email: email }

        json_response = JSON.parse(response.body)
        expect(json_response["otp"]).to eq("123456")
      end
    end

    context "with invalid email format" do
      it "returns unprocessable entity error" do
        post "/auth/request-otp", params: { email: "invalid-email" }

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Invalid email format")
      end
    end

    context "with missing email parameter" do
      it "returns bad request error" do
        post "/auth/request-otp"

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Email is required")
      end
    end
  end

  describe "POST /auth/verify-otp" do
    let(:email) { "test@example.com" }
    let(:otp) { "123456" }
    let(:admin) { User.admin }
    let(:token) { "jwt_token" }

    before do
      allow(User).to receive(:admin).and_return(admin)
      allow(JwtService).to receive(:encode).with(admin.id).and_return(token)
    end

    context "with valid OTP" do
      before do
        allow(OtpService).to receive(:verify).with(email, otp).and_return(true)
      end

      it "returns authentication success" do
        post "/auth/verify-otp", params: { email: email, otp: otp }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Authentication successful")
        expect(json_response["token"]).to eq(token)
        expect(json_response["user"]["id"]).to eq(admin.id)
        expect(json_response["user"]["email"]).to eq(admin.email)
      end

      it "returns admin user" do
        expect(User).to receive(:admin).and_return(admin)

        post "/auth/verify-otp", params: { email: email, otp: otp }

        expect(response).to have_http_status(:ok)
      end

      it "generates JWT token" do
        expect(JwtService).to receive(:encode).with(admin.id).and_return(token)

        post "/auth/verify-otp", params: { email: email, otp: otp }

        json_response = JSON.parse(response.body)
        expect(json_response["token"]).to eq(token)
      end
    end

    context "with invalid OTP" do
      before do
        allow(OtpService).to receive(:verify).with(email, otp).and_return(false)
      end

      it "returns unauthorized error" do
        post "/auth/verify-otp", params: { email: email, otp: otp }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Invalid or expired OTP")
      end
    end

    context "with invalid email format" do
      it "returns unprocessable entity error" do
        post "/auth/verify-otp", params: { email: "invalid-email", otp: otp }

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Invalid email format")
      end
    end

    context "with missing parameters" do
      it "returns bad request error when email is missing" do
        post "/auth/verify-otp", params: { otp: otp }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Email and OTP are required")
      end

      it "returns bad request error when OTP is missing" do
        post "/auth/verify-otp", params: { email: email }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Email and OTP are required")
      end
    end
  end
end
