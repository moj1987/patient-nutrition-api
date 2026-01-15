class OtpMailer < ApplicationMailer
  def send_otp(email, otp)
    @email = email
    @otp = otp
    @expiry_time = 5.minutes.from_now

    mail(
      to: email,
      subject: "Your Authentication Code",
      from: ENV.fetch("FROM_EMAIL", "noreply@patient-nutrition-api.com")
    )
  end
end
