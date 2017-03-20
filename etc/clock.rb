require_relative '../config/boot'
require_relative '../config/environment'

Rails.application.load_tasks

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  every(30.minutes, 'collect_photos', thread: true) do
    task = Rake::Task['collect_photos:twitter']
    task.invoke
    task.reenable
  end

  every(2.hours, 'infer_faces') do
    task = Rake::Task['infer_faces:update']
    task.invoke
    task.reenable
  end

  every(1.day, 'db_backup', at: '00:00') do
    # delete unused photos
    deleted = Photo.where(created_at: Time.zone.today << 2..Time.zone.today << 1).where.not(
      id: Face.select(:photo_id).where(created_at: Time.zone.today << 2..Time.zone.today << 1).group(:photo_id)
    ).delete_all
    logger.info(format('%d photos are deleted', deleted))

    # delete files older than 15 days
    Dir.foreach(dest_dir) do |file|
      path = File.join(dest_dir, file)
      next unless file =~ /.*\.dump$/
      if File.stat(path).ctime < Time.zone.today - 15
        manager.log(format('delete %s', path))
        File.unlink(path)
      end
    end

    next unless (Time.zone.today.yday % 5).zero?

    database = Rails.configuration.database_configuration[Rails.env]['database']
    dest_dir = File.join(Rails.root, 'var', 'backups')
    # dump
    dest = File.join(dest_dir, format('backup-%s.dump', Time.zone.today.to_s))
    cmd = format('pg_dump -Fc --no-acl --no-owner %s > %s', database, dest)
    manager.log(cmd)
    manager.log('backup succeeded') if system(cmd)
  end
end
