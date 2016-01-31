namespace :delete_rows do
  desc 'TODO'

  logger = Logger.new $stderr
  logger.level = Logger::INFO

  task old: :environment do
    sum = Photo.count + Face.count + Label.count
    logger.info(format('sum: %d', sum))
    next if sum < 9000

    Face.where(label_id: nil).order(created_at: :asc).limit(100).each do |face|
      photo = face.photo
      face.destroy
      photo.destroy if photo.faces.empty?
    end
  end
end
