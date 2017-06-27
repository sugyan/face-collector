namespace :misc do
  task check_deleted: :common do
    client = HTTPClient.new
    Photo.find_in_batches(batch_size: 200) do |photos|
      photos.each do |photo|
        begin
          res = client.head(photo.photo_url)
          if res.status == 404
            logger.info(photo.photo_url)
            next unless photo.faces.all? { |face| face.label_id.nil? }
            logger.info("destroy photo: #{photo.id}, face: #{photo.faces.map(&:id).join(', ')}")
            photo.destroy
          end
        rescue => e
          logger.error(e.message)
        end
      end
      sleep 10
    end
  end
end
