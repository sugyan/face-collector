workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup DefaultRackup
port ENV['PORT'] || 3000
environment ENV['RACK_ENV'] || 'development'

project_root = File.join(File.dirname(__FILE__), '..')
pidfile File.join(project_root, 'tmp', 'pids', 'puma.pid')
stdout_redirect File.join(project_root, 'log', 'puma.log'), File.join(project_root, 'log', 'puma-err.log')

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
