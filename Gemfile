ruby File.read(File.join(__dir__, ".ruby-version")).strip
source "https://rubygems.org"

gem "blueimp-templates-rails"
gem "bootstrap-datepicker-rails"
gem "bootstrap-guardsjs-rails"
gem "chartkick"
gem "coffee-rails"
gem "devise", "~> 4.7"
gem "devise-bootstrap-views", "~> 0.0.7"
gem "email_validator", "~> 1.6"
gem "google-api-client", "~> 0.9"
gem "local_time", "~> 1.0"
gem "pg", "~> 0.18"
gem "rails", "~> 5.2"
gem "rake", "~> 12.3"
gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"

gem "bootsnap"
gem "jbuilder", "~> 2.0"
gem "jquery-rails"
gem "turbolinks", "~> 2.5"
# bundle exec rake doc:rails generates the API under doc/api.
gem "active_model_serializers"
gem "awesome_print"
gem "bootstrap-sass", "~> 3.4.1"
gem "geocoder"
gem "gratefulgarment-ui", git: "https://github.com/GratefulGarmentProject/gratefulgarment-ui.git"
gem "jquery-datatables-rails", "~> 3.3.0"
gem "netsuite"
gem "newrelic_rpm"
gem "paper_trail", "~> 12.3"
gem "rack-timeout"
gem "select2-rails"
gem "spreadsheet", "~> 1.1", ">= 1.1.2"
gem "stateful_enum"
gem "twitter-bootstrap-rails-confirm"

group :development, :test do
  gem "capybara"
  gem "dotenv"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rails-controller-testing"
  gem "rspec-rails", "~> 3.4"
  gem "rubocop"
  gem "sdoc", "~> 0.4.0", group: :doc
end

group :test do
  gem "climate_control", "~> 0.2"
  gem "fakefs", "~> 0.11", require: "fakefs/safe"
  gem "shoulda-matchers", "~> 3.1"
end

group :development do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug"

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"

  gem "listen"
end

group :development, :staging, :review do
  gem "letter_opener_web"
end

group :production do
  gem "mailgun_rails"
  gem "sidekiq"
end

group :production, :staging, :review do
  gem "puma", "~> 4.3.9"
  gem "rails_12factor"
end

# This gem needs to be last to ensure it can detect other gems in use
gem "rack-mini-profiler", "~> 0.10"
