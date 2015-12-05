namespace :detect_faces do
  desc "TODO"

  logger = Logger.new $stderr
  logger.level = Logger::INFO

  task detect: :environment do
    conn = Faraday.new(url: 'https://face-detector.herokuapp.com') do |faraday|
      faraday.response :logger, logger
      faraday.adapter :net_http
    end
    Photo.where(faces: nil).each do |photo|
      res = conn.get '/api', url: photo.media_url
      photo.update(faces: res.body)
    end
  end

end
