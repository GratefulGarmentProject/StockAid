# Load the Rails application.
require File.expand_path("../application", __FILE__)

# Load custom exceptions
Dir[Rails.root.join('lib/exceptions/**/*.rb')].each { |f| require f }

# Initialize the Rails application.
Rails.application.initialize!
