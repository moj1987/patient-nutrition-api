class JwtService
  SECRET_KEY = Rails.application.credentials.jwt_secret_key || Rails.application.secret_key_base
  TOKEN_EXPIRY = 5.minutes

  def self.encode(user_id, expires_at = TOKEN_EXPIRY.from_now)
    payload = {
      user_id: user_id,
      exp: expires_at.to_i,
      iat: Time.current.to_i
    }

    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })
    decoded[0]
  rescue JWT::ExpiredSignature
    raise Error::TokenExpired
  rescue JWT::DecodeError
    raise Error::InvalidToken
  end

  def self.user_id_from_token(token)
    payload = decode(token)
    payload["user_id"]
  end

  module Error
    class TokenExpired < StandardError; end
    class InvalidToken < StandardError; end
  end
end
