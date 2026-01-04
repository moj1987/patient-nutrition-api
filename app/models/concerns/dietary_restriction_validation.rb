module DietaryRestrictionValidation
  extend ActiveSupport::Concern
  VALID_RESTRICTIONS = [ "gluten", "lactose", "nuts", "vegetarian", "vegan" ].freeze

  included do
    validate :validate_dietary_restrictions
  end

  private
  def validate_dietary_restrictions
    restrictions = self.dietary_restrictions || []
    invalid_restrictions =  restrictions - VALID_RESTRICTIONS
    if invalid_restrictions.any?
      errors.add(:base, "#{invalid_restrictions} are invalid restrictions. Restrictions can be one of #{VALID_RESTRICTIONS}")
    end
  end
end
