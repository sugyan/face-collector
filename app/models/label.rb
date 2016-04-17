class Label < ActiveRecord::Base
  has_many :faces
  has_many :inferences

  enum status: { enabled: 1, disabled: 0 }
end
