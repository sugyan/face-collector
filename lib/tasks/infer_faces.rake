namespace :infer_faces do
  task eval: :common do
    uri = ENV['CLASSIFIER_API_ENDPOINT']
    client = HTTPClient.new

    total_true = 0
    total_false = 0
    Label.where('index_number > ?', 0).order(index_number: :asc).each do |label|
      true_count = 0
      false_count = 0
      label.faces.each do |face|
        image = face.data
        # TODO: center crop?
        res = client.post(uri, [['images', 'data:image/jpeg;base64,' + Base64.strict_encode64(image)]])
        top = JSON.parse(res.body)['results'].first[0]
        if top['label']['id'] == label.id
          true_count += 1
        else
          false_count += 1
        end
      end
      logger.info(
        format(
          '%2d: %.4f (%d / %d)',
          label.index_number,
          100.0 * true_count / (true_count + false_count),
          true_count,
          true_count + false_count
        )
      )
      total_true += true_count
      total_false += false_count
    end
    logger.info(
      format(
        'total: %.4f (%d / %d)',
        100.0 * total_true / (total_true + total_false),
        total_true,
        total_true + total_false
      )
    )
  end
end
