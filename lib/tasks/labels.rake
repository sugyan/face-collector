namespace :labels do
  desc 'tasks for labels'

  task :reindex, %w(min_faces) => :common do |_task, args|
    args.with_defaults(min_faces: '100')

    # remove all index numbers
    Label.where.not(index_number: nil).each do |label|
      label.update(index_number: nil)
    end

    # "0" label
    Label.find_or_create_by(id: -1).update(index_number: 0)

    faces = Face
      .select(:label_id)
      .where.not(label_id: nil)
      .group(:label_id)
      .having('label_id >= 0')
      .having('COUNT(*) >= ?', args[:min_faces].to_i)
      .order(count: :desc).order(:label_id)
    index = 0
    faces.each do |face|
      label = face.label
      next if label.disabled?
      index += 1
      logger.info format('update label %s (%s) as index %d', label.id, label.name, index)
      label.update(index_number: index)
    end
  end
end
