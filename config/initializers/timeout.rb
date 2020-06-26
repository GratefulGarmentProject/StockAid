Rack::Timeout, service_timeout: (ENV["STOCKAID_RACK_TIMEOUT_SECONDS"].presence || 20).to_i
Rack::Timeout::Logger.logger = Logger.new(Rails.env.production? ? STDOUT : "log/timeout.log")
Rack::Timeout::Logger.logger.level = Logger::ERROR
