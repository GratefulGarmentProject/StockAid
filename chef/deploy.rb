#!/usr/bin/env ruby
require "json"
require "optparse"

# This script is for deploying to the StockAid instance. Unless configured via
# options, it expects to connect via the "chef" user to the "stockaid" host (you
# can set up this host in your ~/.ssh/config file, or provide the real host via
# a command line option).

REMOTE_DIR = File.expand_path("../remote", __FILE__)
CHEF_VERSION = "12.19.36".freeze
SSH_DEFAULTS = { batch: true }.freeze

DEFAULT_OPTIONS = {
  user: "chef",
  host: "stockaid",
  port: 22,
  identity: File.expand_path("~/.ssh/stockaid_rsa"),
  files_dir: File.expand_path("../files", __FILE__),
  repos_dir: File.expand_path("../repos", __FILE__),
  json: File.expand_path("../stockaid.json", __FILE__),
  clear_host: false,
  ssh: false
}.freeze

OPTIONS = Hash.new { |_hash, key| DEFAULT_OPTIONS[key] }

def system_exec(cmd, options = {})
  puts cmd

  if options[:exec]
    exec cmd
  else
    system cmd
  end
end

def ssh_options(options = {})
  options = SSH_DEFAULTS.merge(options)
  result = []
  result << "-o 'BatchMode yes'" if options[:batch]
  result.join(" ")
end

def ssh(command, options = {})
  if command.is_a?(Hash)
    options = options.merge(command)
    options[:batch] = false if options[:exec]
    command = nil
  end

  user = OPTIONS[:user]
  host = OPTIONS[:host]
  port = OPTIONS[:port]
  identity_file = OPTIONS[:identity]

  if options[:exec]
    system_exec "ssh '#{user}@#{host}' -p #{port} -i #{identity_file} #{ssh_options(options)}", exec: true
  else
    force_tty = "-t -t" unless options[:batch]
    system_exec "ssh '#{user}@#{host}' -p #{port} -i #{identity_file} #{force_tty} #{ssh_options(options)} '#{command}'"
  end
end

def scp(from, to, options = {})
  user = OPTIONS[:user]
  host = OPTIONS[:host]
  port = OPTIONS[:port]
  identity_file = OPTIONS[:identity]
  server = "#{user}@#{host}"
  from.sub!(/\Aserver:/, "#{server}:")
  to.sub!(/\Aserver:/, "#{server}:")
  recursive = "-r" if options[:recursive]
  system_exec "scp #{recursive} -P #{port} -i #{identity_file} #{ssh_options(options)} '#{from}' '#{to}'"
end

def rsync(from, to, options = {})
  user = OPTIONS[:user]
  host = OPTIONS[:host]
  port = OPTIONS[:port]
  identity_file = OPTIONS[:identity]
  server = "#{user}@#{host}"
  from.sub!(/\Aserver:/, "#{server}:")
  to.sub!(/\Aserver:/, "#{server}:")
  system_exec %(rsync -e "ssh -p #{port} -i #{identity_file} #{ssh_options(options)}" -av '#{from}' '#{to}')
end

OptionParser.new do |opts|
  opts.banner = "Usage: ./deploy.rb [options]"

  opts.on "-s", "--ssh", "Just ssh to the server, don't actually deploy" do |_ssh|
    OPTIONS[:ssh] = true
  end

  opts.on "-c", "--clear-host", "Clear the host from known hosts" do |clear|
    OPTIONS[:clear_host] = clear
  end

  opts.on "-u", "--user USER", "User to ssh with" do |user|
    OPTIONS[:user] = user
  end

  opts.on "-h", "--host HOST", "Host to ssh with" do |host|
    OPTIONS[:host] = host
  end

  opts.on "-p", "--port PORT", "Port to ssh with" do |port|
    OPTIONS[:port] = port.to_i
  end

  opts.on "-i", "--identity FILE", "Identity file to ssh with" do |identity|
    OPTIONS[:identity] = File.expand_path(identity)
  end

  opts.on "-j", "--json FILE", "Chef json config file" do |config|
    OPTIONS[:json] = File.expand_path(config)
  end
end.parse!

JSON.parse(File.read(OPTIONS[:json])).fetch("meta", {}).each do |key, value|
  next if OPTIONS.include?(key.to_sym)
  puts "Using JSON default #{key}: #{value.inspect}"
  value = File.expand_path(value) if %w(identity files_dir repos_dir).include?(key)
  OPTIONS[key.to_sym] = value
end

ssh exec: true if OPTIONS[:ssh]

system_exec "ssh-keygen -R '#{OPTIONS[:host]}'" if OPTIONS[:clear_host]

unless ssh "echo ssh key is working"
  pub_file = "#{OPTIONS[:identity]}.pub"
  public_key = File.read(pub_file)
  saved_key = ssh %(mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && echo "#{public_key}" >> ~/.ssh/authorized_keys), batch: false
  abort "Failed to save authorized key!" unless saved_key
end

rsync "#{REMOTE_DIR}/", "server:~/next-stockaid-chef"
rsync OPTIONS[:files_dir], "server:~/chef_data/"
rsync OPTIONS[:repos_dir], "server:~/chef_data/"

if OPTIONS[:json]
  puts "Using json file: #{OPTIONS[:json]}"
  scp OPTIONS[:json], "server:~/next-stockaid-chef/solo.json"
end

ssh "sudo ~/next-stockaid-chef/install.sh '#{OPTIONS[:user]}' '#{CHEF_VERSION}'"
