#
# Cookbook:: postgresql_replica
# Recipe:: default
#
package 'postgresql' do
  action :install
end

service 'postgresql' do
  action :stop
end

bash 'setup_replica' do
  code <<-EOH
    pg_version=$(ls /etc/postgresql/)
    pg_data="/var/lib/postgresql/$pg_version/main"

    sudo -u postgres rm -rf $pg_data

    sudo -u postgres PGPASSWORD='replpass' pg_basebackup \
      -h #{node['postgresql_replica']['primary_ip']} \
      -U replicator \
      -D $pg_data \
      -P -Xs -R
  EOH
  action :run
end

service 'postgresql' do
  action :start
end

template '/etc/postgresql/16/main/postgresql.conf' do
  source 'postgresql.conf.erb'
  owner 'postgres'
  group 'postgres'
  mode '0644'
  notifies :restart, 'service[postgresql]'
end