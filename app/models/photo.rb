class Photo < ActiveRecord::Base
  has_many :faces, dependent: :destroy
end
