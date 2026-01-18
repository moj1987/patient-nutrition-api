class Auth::AuthenticationController < ApplicationController
  # POST /auth/token
  def getToken
    return unless is_email_valid
    return unless is_email_authorized

    email = params[:email]
    user = User.find_or_create_by_email(email)

    # Generate JWT token with 5-minute expiry
    token = JwtService.encode(user.id)

    render json: {
      message: "Authentication successful",
      token: token
    }, status: :ok
  end

  private
  def is_email_valid
    email = params[:email]
    if email.blank?
      render json: { error: "Gimme some Email bruh" }, status: :bad_request
      return false
    end
    unless email.match?(URI::MailTo::EMAIL_REGEXP)
      render json: { error: "This ain't no email bruh" }, status: :unprocessable_content
      return false
    end
    true
  end

  def is_email_authorized
    email = params[:email]
    begin
      unless EmailWhitelistService.allowed?(email)
        render json: { error: "Email not in the list bruh" }, status: :unauthorized
        return false
      end
    rescue EmailWhitelistService::ConfigurationError
      render json: { error: "Email not authorized" }, status: :internal_server_error
      return false
    end
    true
  end
end
