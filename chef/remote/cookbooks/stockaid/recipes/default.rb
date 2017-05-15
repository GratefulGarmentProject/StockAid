include_recipe "stockaid::repo"
include_recipe "stockaid::rvm"
include_recipe "stockaid::database"
include_recipe "stockaid::rails"
include_recipe "stockaid::sidekiq"
include_recipe "stockaid::self_signed_ssl"
include_recipe "stockaid::nginx"
include_recipe "stockaid::letsencrypt" if node[:stockaid][:letsencrypt][:enabled]
