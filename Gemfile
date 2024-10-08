ruby File.read(File.join(__dir__, ".ruby-version")).strip
source "https://rubygems.org"

gem "bootstrap-datepicker-rails"
gem "chartkick"
gem "devise", "~> 4.7"
gem "devise-bootstrap-views", "~> 0.0.7"
gem "google-api-client", "~> 0.9"
gem "local_time", "~> 3.0"
gem "pg", "~> 1.1"
gem "rails", "~> 6.0"
gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"

gem "bootsnap"
gem "jbuilder", "~> 2.0"
gem "turbolinks", "~> 2.5"
# bundle exec rake doc:rails generates the API under doc/api.
gem "active_model_serializers"
gem "awesome_print"
gem "bootstrap-sass", "~> 3.4.1"
gem "geocoder"
gem "gratefulgarment-ui", git: "https://github.com/GratefulGarmentProject/gratefulgarment-ui.git"
gem "jquery-datatables-rails", "~> 3.3.0"
gem "netsuite", "~> 0.9"
gem "newrelic_rpm"
gem "paper_trail", "~> 12.3"
gem "rack-timeout"
gem "select2-rails"
gem "shakapacker", "8.0.0"
gem "spreadsheet", "~> 1.1", ">= 1.1.2"
gem "stateful_enum"

group :development, :test do
  gem "capybara"
  gem "dotenv"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rails-controller-testing"
  gem "rspec-rails", "~> 6.0"
  gem "rubocop", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", require: false
  gem "sdoc", group: :doc
end

group :test do
  gem "climate_control", "~> 1.2"
  gem "fakefs", "~> 2.5", require: "fakefs/safe"
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
  gem "puma"
  gem "rails_12factor"
end

# This gem needs to be last to ensure it can detect other gems in use
gem "rack-mini-profiler"
