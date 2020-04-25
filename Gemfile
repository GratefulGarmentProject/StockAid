ruby "2.4.4"
source "https://rubygems.org"

gem "rake", "~> 11.2"
gem "rails", "~> 5.1.7"
gem "pg", "~> 0.18"
gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"
gem "coffee-rails"
gem "devise", "~> 4.7"
gem "devise-bootstrap-views", "~> 0.0.7"
gem "email_validator", "~> 1.6"
gem "bootstrap-datepicker-rails"
gem "bootstrap-guardsjs-rails"
gem "local_time", "~> 1.0"
gem "google-api-client", "~> 0.9"
gem "blueimp-templates-rails"
gem "chartkick"

gem "jquery-rails"
gem "turbolinks", "~> 2.5"
gem "jbuilder", "~> 2.0"
# bundle exec rake doc:rails generates the API under doc/api.
gem "sdoc", "~> 0.4.0", group: :doc
gem "newrelic_rpm"
gem "bootstrap-sass", "~> 3.4.1"
gem "twitter-bootstrap-rails-confirm"
gem "geocoder"
gem "paper_trail", "~> 4.1"
gem "rack-timeout"
gem "gratefulgarment-ui", git: "https://github.com/GratefulGarmentProject/gratefulgarment-ui.git"
gem "jquery-datatables-rails", "~> 3.3.0"
gem "select2-rails"
gem "spreadsheet", "~> 1.1", ">= 1.1.2"
gem "stateful_enum"

group :development, :test do
  gem "capybara"
  gem "rails-controller-testing"
  gem "rspec-rails", "~> 3.4"
  gem "rubocop", "= 0.36"
  gem "awesome_print"
  gem "pry-byebug"
  gem "dotenv"
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
  gem "web-console", "~> 2.0"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "letter_opener"
end

group :production do
  gem "mailgun_rails"
  gem "puma"
  gem "rails_12factor"
  gem "sidekiq"
end

# This gem needs to be last to ensure it can detect other gems in use
gem "rack-mini-profiler", "~> 0.10"
