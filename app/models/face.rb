class Face < ActiveRecord::Base
  belongs_to :photo
  belongs_to :label
end
