default[:stockaid][:github_url] = "https://github.com/on-site/StockAid.git"
default[:stockaid][:home] = "/home/stockaid"
default[:stockaid][:user] = "stockaid"
default[:stockaid][:group] = "stockaid"
default[:stockaid][:dir] = node[:stockaid][:home]
default[:stockaid][:repo_dir] = File.join(node[:stockaid][:dir], "StockAid")
default[:stockaid][:domain] = "orders.gratefulgarment.org"
default[:stockaid][:site_name] = "The Grateful Garment Project"

default[:stockaid][:mailgun][:enabled] = true
default[:stockaid][:mailgun][:domain] = "mg.gratefulgarment.org"
default[:stockaid][:mailgun][:api_key] = nil # This must be set for mailgun to work

default[:stockaid][:letsencrypt][:enabled] = true
default[:stockaid][:letsencrypt][:email] = nil # This must be set for letsencrypt to work

default[:stockaid][:newrelic][:enabled] = true
default[:stockaid][:newrelic][:app_name] = "grateful-garment"
default[:stockaid][:newrelic][:license_key] = nil # This must be set for newrelic to work
