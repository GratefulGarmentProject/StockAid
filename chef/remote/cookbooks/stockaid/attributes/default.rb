default[:stockaid][:github_url] = "https://github.com/on-site/StockAid.git"
default[:stockaid][:home] = "/home/stockaid"
default[:stockaid][:user] = "stockaid"
default[:stockaid][:group] = "stockaid"
default[:stockaid][:dir] = node[:stockaid][:home]
default[:stockaid][:repo_dir] = File.join(node[:stockaid][:dir], "StockAid")
default[:stockaid][:domain] = "orders.gratefulgarment.org"
default[:stockaid][:use_letsencrypt] = true

# This must be set for letsencrypt to work
default[:stockaid][:letsencrypt_email] = nil
