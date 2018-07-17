# Recommended in https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#timeout
Rack::Timeout.timeout = (ENV["STOCKAID_RACK_TIMEOUT_SECONDS"].presence || 20).to_i # seconds
