namespace :detect_faces do
  desc "TODO"

  logger = Logger.new $stderr
  logger.level = Logger::INFO

  task detect: :environment do
    conn = Faraday.new(url: 'https://face-detector.herokuapp.com') do |faraday|
      faraday.response :logger, logger
      faraday.adapter :net_http
    end
    Photo.where(detected: nil).each do |photo|
      res = conn.get '/api', url: photo.media_url
      faces = JSON.parse(res.body)['faces']
      logger.info('%s faces detected' % faces.size)
      if faces.size > 0
        photo.update(detected: res.body)
      else
        photo.delete()
      end
    end
  end

end
