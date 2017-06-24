namespace :misc do
  task check_deleted: :common do
    client = HTTPClient.new
    Photo.find_in_batches(batch_size: 200) do |photos|
      photos.each do |photo|
        res = client.head(photo.photo_url)
        next if res.ok?
        logger.info("#{res.status}: #{photo.photo_url}")
        next unless photo.faces.all? { |face| face.label_id.nil? }
        logger.info("destroy photo: #{photo.id}, face: #{photo.faces.map(&:id).join(', ')}")
        photo.destroy
      end
      sleep 10
    end
  end
end
