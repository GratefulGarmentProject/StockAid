require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if !Rails.env.production? && !Rails.env.staging? && !Rails.env.review? && File.exist?("./.ruby-env")
  File.readlines("./.ruby-env").each do |line|
    line = line.strip
    next if line.empty?
    key, value = line.split("=", 2)
    ENV[key] = value
  end
end

module StockAid
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    require "percentage_display"
    require "down_for_maintenance"
    config.middleware.unshift DownForMaintenance

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.before_initialize do
      require "environment_setup"
      EnvironmentSetup.check_setup
    end

    config.to_prepare do
      Dir.glob(Rails.root.join("app", "overrides", "**", "*_override.rb")).each do |override|
        require_dependency override
      end
    end
  end
end
