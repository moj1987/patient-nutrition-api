class Patient < ApplicationRecord
    enum :status, { active: 0, dischared: 1 }
end
