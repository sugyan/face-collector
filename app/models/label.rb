class Label < ActiveRecord::Base
  has_many :faces
  has_many :inferences
end
