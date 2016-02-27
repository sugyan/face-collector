def logger
  Rails.logger
end

task common: %i(environment) do
  Rails.logger = Logger.new(STDOUT)
  Rails.logger.level = Logger::INFO
end
