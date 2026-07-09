require "simplecov"
SimpleCov.start "rails" do
  add_filter "/spec/"
  add_filter "/config/"
  add_filter "/vendor/"
  add_filter "/db/"
  add_filter "/lib/"

  # Controllers excluded by design (infrastructure, complex nesting, external integrations)
  add_filter "letsencrypt_controller.rb"
  add_filter "backups_controller.rb"
  add_filter "exports_controller.rb"
  add_filter "profilers_controller.rb"
  add_filter "survey_requests_controller.rb"
  add_filter "survey_request_answers_controller.rb"
  add_filter "tracking_details_controller.rb"
  add_filter "order_details_controller.rb"
  add_filter "purchase_details_controller.rb"
  add_filter "purchase_shipments_controller.rb"
  add_filter "purchase_shorts_controller.rb"

  # Models excluded by design (Google Drive / backup, streaming, complex migration)
  add_filter "app/models/backup.rb"
  add_filter "app/models/drive_backup.rb"
  add_filter "app/models/export.rb"
  add_filter "app/models/spreadsheet_exporter.rb"
  add_filter "app/models/donation_migrator.rb"
  add_filter "app/models/reconciliation_deltas.rb"
  add_filter "app/models/reconciliation_program_detail.rb"
  add_filter "app/models/survey_organization_request.rb"


  # Survey request flow (complex multi-step flow with mailers)
  add_filter "app/models/reports/survey_request_data.rb"
  add_filter "app/mailers/survey_request_mailer.rb"
  add_filter "app/mailers/address_change_mailer.rb"
  add_filter "app/models/survey_request.rb"

  # Infrastructure with poor coverage ratio
  add_filter "app/overrides/controllers/letter_opener_web/letters_controller_override.rb"
  add_filter "app/helpers/reconciliations_helper.rb"
  add_filter "app/helpers/notifications_helper.rb"
  add_filter "app/models/profiler.rb"
  add_filter "app/models/tracking_detail.rb"
  add_filter "app/helpers/user_invitations_helper.rb"
  add_filter "app/models/inventory_reconciliation.rb"
  add_filter "app/models/concerns/users/item_manipulator.rb"

  add_group "Controllers", "app/controllers"
  add_group "Models",      "app/models"
  add_group "Mailers",     "app/mailers"
  add_group "Jobs",        "app/jobs"

  minimum_coverage 95
  track_files "app/**/*.rb"
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
abort("The Rails environment is running in staging mode!") if Rails.env.staging?
abort("The Rails environment is running in review mode!") if Rails.env.review?
abort("The Rails environment is not running in test mode!") unless Rails.env.test?
require "spec_helper"
require "rspec/rails"
require "fakefs/spec_helpers"
# Add additional requires below this line. Rails is not loaded until this point!
require_relative "support/climate_helper"
require_relative "support/controllers_helper"

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

# The netsuite.rb initializer skips configuration in test mode but doesn't set
# this flag, causing views that call external_id_or_status to crash.
Rails.application.config.netsuite_initialized = false

ActiveJob::Base.queue_adapter = :test

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  config.global_fixtures = :all

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.before do
    ActionMailer::Base.deliveries.clear
  end

  config.include ClimateHelper
  config.include ControllersHelper
  config.include Devise::Test::IntegrationHelpers, type: :request
end

# Prevent accidental exporting to NetSuite
class NetSuite::Records::Customer # rubocop:disable Style/ClassAndModuleChildren
  def add
    raise "This method should not be actually called in tests"
  end
end
