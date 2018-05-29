package "git"

directory node[:stockaid][:dir] do
  owner node[:stockaid][:user]
  group node[:stockaid][:group]
  recursive true
end

execute "git-clone-stockaid" do
  command "git clone '#{node[:stockaid][:github_url]}' '#{node[:stockaid][:repo_dir]}'"
  user node[:stockaid][:user]
  group node[:stockaid][:group]
  not_if { File.exist?(File.join(node[:stockaid][:repo_dir], ".git")) }
end
