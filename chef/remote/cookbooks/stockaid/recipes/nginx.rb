%w(
  apt-transport-https
  ca-certificates
).each do |pkg|
  package pkg
end

apt_key = "561F9B9CAC40B2F7"

execute "add-passenger-apt-key" do
  command "apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-keys '#{apt_key}'"

  not_if do
    `apt-key finger`.split("\n").map do |line|
      line[/Key fingerprint = ([0-9A-F ]+)/, 1]
    end.compact.map do |fingerprint|
      fingerprint.split.join
    end.any? do |fingerprint|
      fingerprint.end_with? apt_key
    end
  end
end

file "/etc/apt/sources.list.d/passenger.list" do
  content lazy {
    ubuntu_codename = `lsb_release -s -c`.strip
    "deb https://oss-binaries.phusionpassenger.com/apt/passenger #{ubuntu_codename} main"
  }

  owner "root"
  group "root"
  mode "0644"
end

execute "update-apt" do
  command "apt-get update"
  action :nothing
end

%w(
  nginx-extras
  passenger
).each do |pkg|
  package pkg do
    options "--force-yes"
    notifies :run, "execute[update-apt]", :before
    notifies :run, "execute[reload-nginx]", :immediately
  end
end

template "/etc/nginx/sites-available/default" do
  source "nginx/default.nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :run, "execute[reload-nginx]"
end

link "/etc/nginx/conf.d/passenger.conf" do
  to "/etc/nginx/passenger.conf"
  notifies :run, "execute[reload-nginx]"
end

template "/etc/nginx/sites-available/stockaid" do
  source "nginx/stockaid.nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"

  variables(
    lazy do
      stockaid_ruby_file = File.join(node[:stockaid][:repo_dir], ".ruby-version")
      ruby = File.read(stockaid_ruby_file).strip

      if File.exist?("/etc/letsencrypt/live/#{node[:stockaid][:domain]}/fullchain.pem")
        certificate = "/etc/letsencrypt/live/#{node[:stockaid][:domain]}/fullchain.pem"
        certificate_key = "/etc/letsencrypt/live/#{node[:stockaid][:domain]}/privkey.pem"
      else
        certificate = "/etc/self-signed-ssl/stockaid.crt"
        certificate_key = "/etc/self-signed-ssl/stockaid.key"
      end

      {
        domain: node[:stockaid][:domain],
        passenger_ruby: File.join(node[:stockaid][:home], ".rvm/wrappers/#{ruby}/ruby"),
        rails_root: node[:stockaid][:repo_dir],
        certificate: certificate,
        certificate_key: certificate_key,
        env: StockAid::Helper.stockaid_environment(node)
      }
    end
  )

  notifies :run, "execute[reload-nginx]", :immediately
end

link "/etc/nginx/sites-enabled/stockaid" do
  to "/etc/nginx/sites-available/stockaid"
  notifies :run, "execute[reload-nginx]", :immediately
end

execute "reload-nginx" do
  command "systemctl reload nginx"
  ignore_failure true
  action :nothing
end
