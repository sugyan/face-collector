namespace :dataset do
  desc 'generate dataset files for train'

  task train: :common do
    num_samples = (ENV['NUM_SAMPLES'] || 120).to_i

    trunc = {}
    Label.where.not(index_number: nil).order(index_number: :asc).each do |label|
      n = (label.index_number - 1) / 10 + 1
      filename = format('data-%03d.tfrecords', n)
      mode = trunc[filename] ? 'ab' : 'wb'
      trunc[filename] = true
      Rails.root.join('var', 'data', 'tfrecords', filename).open(mode) do |file|
        faces = label.faces
        logger.info(format('write %d faces to %s', [faces.count, num_samples].min, file.path))
        faces.sample(num_samples).each do |face|
          # TODO: double?
          file.write(face.tfrecord)
        end
      end
    end
    # TODO: add faces of disabled labels
  end
end

namespace :dataset do
  desc 'generate dataset files for eval'

  task eval: :common do
    num_labels    = (ENV['NUM_LABELS']    || 120).to_i
    num_samples   = (ENV['NUM_SAMPLES']   || 200).to_i
    num_tfrecords = (ENV['NUM_TFRECORDS'] || 5).to_i
    # devide sampled faces
    records = []
    Label.where.not(id: -1).order(:index_number).limit(num_labels).each do |label|
      size = (num_samples / num_tfrecords).to_i
      label.faces.sample(num_samples).each_slice(size).each.with_index do |arr, i|
        (records[i] ||= []).concat(arr)
      end
    end
    # write to tfrecords file
    logger.info(format('%s faces', records.map(&:size).join(', ')))
    records.each.with_index do |faces, i|
      filename = format('data-%02d.tfrecords', i)
      logger.info(format('write to %s...', filename))
      Rails.root.join('var', 'data', 'tfrecords', filename).open('wb') do |file|
        faces.shuffle!.each do |face|
          file.write(face.tfrecord(-1))
        end
      end
    end
  end
end
