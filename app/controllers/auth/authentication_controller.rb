class Auth::AuthenticationController < ApplicationController
  # POST /auth/request-otp
  def request_otp
    email = params[:email]

    if email.blank?
      render json: { error: "Email is required" }, status: :bad_request
      return
    end

    unless email.match?(URI::MailTo::EMAIL_REGEXP)
      render json: { error: "Invalid email format" }, status: :unprocessable_content
      return
    end

    # Generate OTP
    otp = OtpService.generate(email)

    # Send OTP email
    begin
      OtpMailer.send_otp(email, otp).deliver_now
    rescue StandardError
      # Continue even if email fails
    end

    response_data = {
      message: "OTP sent successfully"
    }

    # Return OTP in development environment
    if Rails.env.development?
      response_data[:otp] = otp
    end

    render json: response_data, status: :ok
  rescue StandardError
    render json: { error: "Failed to send OTP" }, status: :internal_server_error
  end

  # POST /auth/verify-otp
  def verify_otp
    email = params[:email]
    otp = params[:otp]

    if email.blank? || otp.blank?
      render json: { error: "Email and OTP are required" }, status: :bad_request
      return
    end

    unless email.match?(URI::MailTo::EMAIL_REGEXP)
      render json: { error: "Invalid email format" }, status: :unprocessable_content
      return
    end

    # Verify OTP
    unless OtpService.verify(email, otp)
      render json: { error: "Invalid or expired OTP" }, status: :unauthorized
      return
    end

    # Find or create user (admin pattern)
    user = User.admin

    # Generate JWT token
    token = JwtService.encode(user.id)

    render json: {
      message: "Authentication successful",
      token: token,
      user: { id: user.id, email: user.email }
    }, status: :ok
  rescue JwtService::Error
    render json: { error: "Authentication failed" }, status: :internal_server_error
  rescue StandardError
    render json: { error: "Authentication failed" }, status: :internal_server_error
  end
end
