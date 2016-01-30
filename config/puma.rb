# This file is copied from Heroku's recommendations at
# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server
# with some small changes

workers Integer(ENV["WEB_CONCURRENCY"] || 2)
threads_count = Integer(1)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV["PORT"]     || 3000
environment ENV["RACK_ENV"] || "development"

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
