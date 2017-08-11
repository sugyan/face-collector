# rubocop:disable Metrics/BlockLength
namespace :dataset do
  desc 'generate dataset files for train'

  task train: :common do
    num_samples = ENV.fetch('NUM_SAMPLES', '120').to_i
    num_files = ENV.fetch('NUM_FILES', '50').to_i

    # collect target ids
    label_ids = Array.new(num_files) { [] }
    Label.where.not(index_number: nil).each do |label|
      next if label.index_number.zero?
      label_ids[label.index_number % num_files] << label.id
    end
    zero_count = Label.find(-1).faces.count
    logger.info("index 0: #{zero_count}")
    label_ids[0] << -1
    Label.where(index_number: nil).where(status: :disabled).each.with_index do |label, i|
      label_ids[i % (num_files - 1) + 1] << label.id
      zero_count += [label.faces.count, 20].min
    end
    logger.info("index 0 (total): #{zero_count}")
    # generate tfrecords files
    label_ids.each.with_index do |ids, i|
      filename = format('data-%03d.tfrecords', i)
      logger.info("write to #{filename}:")
      Rails.root.join('var', 'data', 'tfrecords', filename).open('wb') do |file|
        Label.where(id: ids).each do |label|
          faces = label.faces
          sample = [faces.count, num_samples].min
          sample = [sample, 20].min if label.disabled?
          sample = faces.count if label.id == -1
          n = label.enabled? && sample <= num_samples / 2 ? 2 : 1
          logger.info("  (#{label.index_number}) #{label.name}: #{sample}" + (n == 2 ? ' x2' : ''))
          n.times do
            faces.sample(sample).each do |face|
              file.write(face.tfrecord)
            end
          end
        end
      end
    end
    # labels
    labels = {}
    Label.where.not(index_number: nil).each do |label|
      next if label.index_number.zero?
      labels[label.index_number] = label.as_json
        .slice('id', 'name', 'description', 'twitter')
        .merge(count: label.faces.count)
    end
    Rails.root.join('var', 'data', 'tfrecords', 'labels.json').open('wb') do |file|
      file.write(labels.to_json)
    end
  end

  desc 'generate dataset files'
  task :classes, [:num_classes] => :common do |_, args|
    args.with_defaults(num_classes: '10')
    num_classes = args.num_classes.to_i
    # collect target ids
    num_faces = Float::INFINITY
    label_ids = Array.new(10) { [] }
    Label.where.not(index_number: nil).where('index_number < ?', num_classes).each do |label|
      label_ids[label.index_number % 10] << label.id
      num_faces = [label.faces.count, num_faces].min
    end
    num_faces = [num_faces - (num_faces % 10), 300].min
    logger.info("labels: #{num_classes}: faces: #{num_faces}")
    # generate tfrecords files
    label_ids.each.with_index do |ids, i|
      filename = format('data-%02d.tfrecords', i)
      logger.info("write to #{filename}:")
      Rails.root.join('var', 'data', 'tfrecords', filename).open('wb') do |file|
        Label.where(id: ids).each do |label|
          faces = label.faces
          logger.info("  (#{label.index_number}) #{label.name}: #{num_faces}")
          faces.sample(num_faces).each do |face|
            file.write(face.tfrecord)
          end
        end
      end
    end
    # labels
    labels = {}
    Label.where.not(index_number: nil).where('index_number < ?', num_classes).each do |label|
      next if label.index_number.zero?
      labels[label.index_number] = label.as_json.slice('id', 'name', 'description', 'twitter')
    end
    Rails.root.join('var', 'data', 'tfrecords', 'labels.json').open('wb') do |file|
      file.write(labels.to_json)
    end
  end

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
