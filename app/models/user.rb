class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def self.find_or_create_by_email(email)
    find_or_create_by(email: email.downcase.strip)
  end

  def self.admin
    first || create!(email: "m29038015@gmail.com")
  end
end
