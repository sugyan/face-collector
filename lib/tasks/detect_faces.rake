require 'rvg/rvg'

namespace :detect_faces do
  desc "TODO"

  logger = Logger.new $stderr
  logger.level = Logger::INFO

  task detect: :environment do
    SIZE = 224
    conn = Faraday.new(url: 'https://face-detector.herokuapp.com') do |faraday|
      faraday.response :logger, logger
      faraday.adapter :net_http
    end
    Photo.all.each do |photo|
      # already exists?
      next if not photo.faces.empty?
      begin
        res = conn.get '/api', url: photo.media_url
        data = JSON.parse(res.body)
        if data['error']
          logger.error(data['error'])
          next
        end
        faces = data['faces']
        # not found?
        if faces.empty?
          photo.delete
          next
        end

        img = Magick::Image.read(photo.media_url).first
        faces.each do |face|
          eyes = face['eyes']
          eye_l, eye_r = eyes[0]['x'] < eyes[1]['x'] ? [eyes[0], eyes[1]] : [eyes[1], eyes[0]]
          rad = Math::atan2((eye_r['y'] - eye_l['y']) * img.rows, (eye_r['x'] - eye_l['x']) * img.columns)
          rvg = Magick::RVG.new(SIZE, SIZE) do |canvas|
            scale = SIZE / [face['w'] * img.columns / 100.0, face['h'] * img.rows / 100.0].max
            canvas.image(img)
              .translate(SIZE * 0.5, SIZE * 0.5)
              .scale(scale)
              .rotate(-rad * 180.0 / Math::PI)
              .translate(-face['center']['x'] * img.columns / 100.0, -face['center']['y'] * img.rows / 100.0)
          end
          Face.create(
            photo: photo,
            data: rvg.draw.to_blob{ self.format = 'JPG' },
          )
        end
      rescue Exception => e
        logger.error(e)
      end
    end
  end

end
