package "letsencrypt"

raise "node[:stockaid][:letsencrypt][:email] is not set!" unless node[:stockaid][:letsencrypt][:email]

template "/usr/bin/stockaid_letsencrypt_renew" do
  source "letsencrypt/stockaid_letsencrypt_renew.erb"
  owner "root"
  group "root"
  mode "0744"
atend

file "/etc/cron.d/letsencrypt_renew" do
  content "# This file is managed by chef
0 5 * * * root /usr/bin/stockaid_letsencrypt_renew >> /var/log/letsencrypt-renew.log
"
  owner "root"
  group "root"
  mode "0644"
end

directory "/var/www-letsencrypt/#{node[:stockaid][:domain]}" do
  owner "www-data"
  group "www-data"
  mode "0744"
  recursive true
end

execute "setup-letsencrypt" do
  command "letsencrypt certonly --non-interactive --agree-tos --email '#{node[:stockaid][:letsencrypt][:email]}' " \
          "--webroot -w '/var/www-letsencrypt/#{node[:stockaid][:domain]}' -d '#{node[:stockaid][:domain]}'"
  creates "/etc/letsencrypt/live/#{node[:stockaid][:domain]}"
  notifies :run, "execute[reload-nginx]", :before
  notifies :create, "template[/etc/nginx/sites-available/stockaid]", :immediately
end
