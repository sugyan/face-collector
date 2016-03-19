class Inference < ActiveRecord::Base
  belongs_to :face
  belongs_to :label
end
