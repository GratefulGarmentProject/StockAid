directory "/var/log" do
  owner "root"
  group "root"
  mode "0775"
  recursive true
end

file "/etc/cron.weekly/apt-auto-updates" do
  content %(# This file is managed by Chef
echo "**************" >> /var/log/apt-auto-updates.log
date >> /var/log/apt-auto-updates.log
apt-get update >> /var/log/apt-auto-updates.log
apt-get upgrade --assume-yes >> /var/log/apt-auto-updates.log
echo "Updates (if any) installed"
)
  owner "root"
  group "root"
  mode "0755"
end

file "/etc/logrotate.d/apt-auto-updates" do
  content %(# This file is managed by Chef
/var/log/apt-auto-updates.log {
  rotate 20
  weekly
  size 500k
  compress
  notifempty
}
)
end
