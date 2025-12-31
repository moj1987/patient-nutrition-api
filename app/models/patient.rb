class Patient < ApplicationRecord
    enum :status, { active: 0, discharged: 1 }
end
