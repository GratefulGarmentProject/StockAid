# The self signed cert will be used until lets encrypt is ready
directory "/etc/self-signed-ssl" do
  owner "root"
  group "root"
  mode "0700"
  recursive true
end

execute "generate-self-signed-cert" do
  command %{openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/self-signed-ssl/stockaid.key -out /etc/self-signed-ssl/stockaid.crt -subj "/C=/ST=/L=/O=/OU=/CN=#{node[:stockaid][:domain]}"}
  not_if { File.exist?("/etc/self-signed-ssl/stockaid.key") && File.exist?("/etc/self-signed-ssl/stockaid.crt") }
end
