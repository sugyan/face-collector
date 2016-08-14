class Label < ApplicationRecord
  has_many :faces
  has_many :inferences

  enum status: { enabled: 1, disabled: 0 }
end
