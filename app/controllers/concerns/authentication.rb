module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    auth_header = request.headers["Authorization"]

    if auth_header.blank?
      render json: { error: "Authentication required" }, status: :unauthorized
      return
    end

    # Check for Bearer token format
    unless auth_header.start_with?("Bearer ")
      render json: { error: "Authentication required" }, status: :unauthorized
      return
    end

    token = auth_header.split(" ").last

    if token.blank?
      render json: { error: "Authentication required" }, status: :unauthorized
      return
    end

    begin
      JwtService.decode(token) # Just validate token is valid
      @current_user = User.admin # Single admin user manages all patients
    rescue JwtService::Error::TokenExpired
      render json: { error: "Token expired" }, status: :unauthorized
    rescue JwtService::Error::InvalidToken
      render json: { error: "Invalid token" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
