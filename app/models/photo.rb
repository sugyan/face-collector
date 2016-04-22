class Photo < ActiveRecord::Base
  include ModelImage
  has_many :faces, dependent: :destroy

  def face_images(size)
    detected = detect_faces(photo_url, size)
    img = MiniMagick::Image.open(photo_url)
    results = detected.map do |face|
      eyes = face['eyes']
      eye_l, eye_r = eyes[0]['x'] < eyes[1]['x'] ? [eyes[0], eyes[1]] : [eyes[1], eyes[0]]
      rad = Math.atan2((eye_r['y'] - eye_l['y']) * img.height, (eye_r['x'] - eye_l['x']) * img.width)
      srt = [
        "#{face['center']['x'] * img.width / 100.0},#{face['center']['y'] * img.height / 100.0}",
        size / [face['w'] * img.width / 100.0, face['h'] * img.height / 100.0].max,
        - rad * 180.0 / Math::PI,
        "#{size * 0.5},#{size * 0.5}"
      ].join(' ')
      face_image = MiniMagick::Image.open(img.path)
      face_image.mogrify do |convert|
        convert.background('black')
        convert.virtual_pixel('background')
        convert.distort(:SRT, srt)
        convert.crop("#{size}x#{size}+0+0")
      end
      { data: face_image.to_blob, json: face }
    end
    img.destroy!
    results
  end
end
