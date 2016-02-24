require_relative '../config/boot'
require_relative '../config/environment'

Rails.application.load_tasks

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  every(1.hour, 'collect photos') do
    Rake::Task['collect_photos:twitter'].invoke
  end

  every(1.day, 'db backup', at: '00:00') do
    database = Rails.configuration.database_configuration[Rails.env]['database']
    dest = File.join(Rails.root, 'var', 'backups', format('backup-%s.dump', Time.zone.today.to_s))
    cmd = format('pg_dump -Fc --no-acl --no-owner -h localhost %s > %s', database, dest)
    puts 'backup succeeded' if system(cmd)
  end
end
