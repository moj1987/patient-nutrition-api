class OtpService
  OTP_LENGTH = 6
  OTP_EXPIRY = 5.minutes

  def self.generate(email)
    otp = sprintf("%0#{OTP_LENGTH}d", rand(10**OTP_LENGTH))
    redis_key = "otp:#{email.downcase}"

    # Store OTP with expiry
    $redis.setex(redis_key, OTP_EXPIRY, otp)

    otp
  end

  def self.verify(email, provided_otp)
    redis_key = "otp:#{email.downcase}"
    stored_otp = $redis.get(redis_key)

    return false unless stored_otp
    return false unless stored_otp == provided_otp.to_s

    # Consume the OTP after successful verification
    $redis.del(redis_key)
    true
  end

  def self.exists?(email)
    redis_key = "otp:#{email.downcase}"
    $redis.exists?(redis_key)
  end
end
