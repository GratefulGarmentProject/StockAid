template "/etc/systemd/system/sidekiq.service" do
  source "sidekiq/sidekiq.service.erb"
  owner "root"
  group "root"
  mode "0600"

  variables lazy {
    require "yaml"
    procfile_file = File.join(node[:stockaid][:repo_dir], "Procfile")
    procfile = YAML.load_file(procfile_file)

    {
      command: procfile["worker"],
      env: StockAid::Helper.stockaid_environment(node)
    }
  }
end

service "sidekiq" do
  action [:enable, :start]
  subscribes :reload, "template[/etc/systemd/system/sidekiq.service]", :immediately
end
