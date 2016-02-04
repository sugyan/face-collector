class Photo < ActiveRecord::Base
  has_many :faces, dependent: :destroy

  def image
    Magick::Image.read(photo_url).first
  end
end
