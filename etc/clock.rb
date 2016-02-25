require_relative '../config/boot'
require_relative '../config/environment'

Rails.application.load_tasks

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  every(1.hour, 'collect_photos', thread: true) do
    Rake::Task['collect_photos:twitter'].execute
  end

  every(1.hour, 'delete_rows') do
    Face.where(label_id: nil).order(created_at: :asc).limit(20).each do |face|
      photo = face.photo
      face.destroy
      manager.log(format('face %d destroyed.', face.id))
      photo.destroy if photo.faces.empty?
    end
  end

  every(1.day, 'db_backup', at: '00:00') do
    database = Rails.configuration.database_configuration[Rails.env]['database']
    dest = File.join(Rails.root, 'var', 'backups', format('backup-%s.dump', Time.zone.today.to_s))
    cmd = format('pg_dump -Fc --no-acl --no-owner -h localhost %s > %s', database, dest)
    puts 'backup succeeded' if system(cmd)
  end
end
