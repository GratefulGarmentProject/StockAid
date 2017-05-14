%w(
  autoconf
  automake
  bison
  curl
  gawk
  libffi-dev
  libgdbm-dev
  libncurses5-dev
  libreadline6-dev
  libsqlite3-dev
  libssl-dev
  libtool
  libyaml-dev
  pkg-config
  sqlite3
  zlib1g-dev
).each do |pkg|
  package pkg
end

gpg_key = "409B6B1796C275462A1703113804BB82D39DC0E3"
stockaid_ruby_file = File.join(node[:stockaid][:repo_dir], ".ruby-version")
rvm_binary = File.join node[:stockaid][:home], ".rvm/bin/rvm"
rvm_environment = {
  "USER" => node[:stockaid][:user],
  "HOME" => node[:stockaid][:home],
  "TERM" => "dumb"
}

execute "install-rvm-key" do
  command "gpg --keyserver hkp://keys.gnupg.net --recv-keys #{gpg_key}"
  user node[:stockaid][:user]
  group node[:stockaid][:group]
  environment rvm_environment
  not_if "gpg -k #{gpg_key}", user: node[:stockaid][:user], environment: rvm_environment
end

execute "install-rvm" do
  command "curl -sSL https://get.rvm.io | bash -s stable --autolibs=read-fail"
  user node[:stockaid][:user]
  group node[:stockaid][:group]
  environment rvm_environment
  not_if { File.exist?(File.join(node[:stockaid][:home], ".rvm")) }
end

execute "rvm-install-ruby" do
  command lazy { "#{rvm_binary} install #{File.read(stockaid_ruby_file).strip}" }
  user node[:stockaid][:user]
  group node[:stockaid][:group]
  environment rvm_environment
  not_if { File.exist?(File.join(node[:stockaid][:home], ".rvm/rubies/#{File.read(stockaid_ruby_file).strip}")) }
end
