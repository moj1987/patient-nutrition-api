class EmailWhitelistService
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class EmailNotAllowed < Error; end

  def self.allowed?(email)
    validate_configuration!

    normalized_email = email.downcase.strip
    whitelisted_emails.include?(normalized_email)
  end

  def self.validate_configuration!
    allowed_emails = ENV["ALLOWED_EMAILS"]

    if allowed_emails.blank?
      raise ConfigurationError, "ALLOWED_EMAILS environment variable is not configured"
    end
  end

  def self.whitelisted_emails
    @whitelisted_emails ||= begin
      emails = ENV.fetch("ALLOWED_EMAILS", "").split(",").map(&:strip)
      emails.map(&:downcase).reject(&:blank?)
    end
  end

  def self.reset_cache!
    @whitelisted_emails = nil
  end
end
