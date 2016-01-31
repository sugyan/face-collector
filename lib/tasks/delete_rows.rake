namespace :delete_rows do
  desc 'TODO'

  logger = Logger.new $stderr
  logger.level = Logger::INFO

  task old: :environment do
    sum = Photo.count + Face.count + Label.count
    logger.info(format('sum: %d', sum))
    next if sum < 9000

    Photo.order(created_at: :asc).limit(100).each do |photo|
      photo.destroy if photo.faces.all? { |face| face.label_id.nil? }
    end
  end
end
