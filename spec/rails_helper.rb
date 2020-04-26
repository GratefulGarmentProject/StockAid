ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "spec_helper"
require "rspec/rails"
require "fakefs/spec_helpers"
# Add additional requires below this line. Rails is not loaded until this point!
require_relative "support/climate_helper"
require_relative "support/controllers_helper"

# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true
  config.global_fixtures = :all
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before do
    allow(Geocoder).to receive(:search) do |_search|
      [double(address_components: [{ "types" => ["administrative_area_level_2"],
                                     "short_name" => "Alameda County" }],
              latitude: 142.0,
              longitude: 104.2)]
    end
  end

  config.before do
    ActionMailer::Base.deliveries.clear
  end

  config.include ClimateHelper
  config.include ControllersHelper
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
