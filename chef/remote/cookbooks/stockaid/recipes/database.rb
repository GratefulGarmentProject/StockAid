%w(
  postgresql
  libpq-dev
).each do |pkg|
  package pkg
end

password_file = File.join(node[:stockaid][:dir], ".stockaid-db-password")

file password_file do
  content lazy { `openssl rand -base64 18` }
  user node[:stockaid][:user]
  group node[:stockaid][:group]
  mode "0600"
  action :create_if_missing
end

execute "create-postgres-user" do
  command lazy { %(psql -c "CREATE USER \\"stockaid\\" WITH LOGIN PASSWORD '#{File.read(password_file).strip}'") }
  user "postgres"
  not_if %{psql postgres -tAc "SELECT 1 FROM pg_roles WHERE LOWER(rolname) = 'stockaid'" | grep 1}, user: "postgres"
end

execute "create-postgres-database" do
  command lazy { %(psql -c "CREATE DATABASE \\"stockaid_production\\" WITH OWNER \\"stockaid\\" ENCODING 'unicode'") }
  user "postgres"
  not_if %{psql postgres -tAc "SELECT 1 FROM pg_database WHERE LOWER(datname) = 'stockaid_production'" | grep 1}, user: "postgres"
  notifies :run, "execute[grant-postgres-database-to-user]", :immediately
end

execute "grant-postgres-database-to-user" do
  command %(psql -c "GRANT ALL PRIVILEGES ON DATABASE \\"stockaid_production\\" TO \\"stockaid\\"")
  user "postgres"
  action :nothing
end
