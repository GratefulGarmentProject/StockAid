web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -q default -q mailers -e production -c 1
