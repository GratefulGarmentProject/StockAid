desc "Use a STDOUT logger in addition to normal logging"
task stdout_logger: :environment do
  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO
  Rails.logger.extend(ActiveSupport::Logger.broadcast(logger))
end
