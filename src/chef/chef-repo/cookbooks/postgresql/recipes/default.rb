#
# Cookbook:: postgresql
# Recipe:: default
#
# Copyright:: 2026, The Authors, All Rights Reserved.
package 'postgresql' do
  action :install
end

# Ensure PostgreSQL is running and enabled
service 'postgresql' do
  action [:enable, :start]
end

# First, ensure the parent directory exists
directory '/opt/fleetapp' do
  owner 'www-data'
  group 'www-data'
  mode '0755'
  action :create
end

# Then create the file
file '/opt/fleetapp/app.py' do
  owner 'www-data'
  group 'www-data'
  content <<-EOH
from flask import Flask, jsonify
import psycopg2
import time
  EOH
  action :create
end

# Create the app database and user
bash 'setup_database' do
  user 'postgres'
  code <<-EOH
    psql -c "SELECT 1 FROM pg_roles WHERE rolname='fleetapp'" | grep -q 1 || \
      psql -c "CREATE USER fleetapp WITH PASSWORD 'fleetpass';"
    psql -c "SELECT 1 FROM pg_database WHERE datname='fleetdb'" | grep -q 1 || \
      psql -c "CREATE DATABASE fleetdb OWNER fleetapp;"
  EOH
  action :run
  only_if { node['db']['role'] == 'primary' }
end

bash 'Create Table' do
  user 'postgres'
  code <<-EOH
    psql -d fleetdb -c "CREATE TABLE IF NOT EXISTS nodes (
      name TEXT UNIQUE
    );"
    psql -d fleetdb -c "INSERT INTO nodes (name) VALUES
      ('Control: Ansible playbooks runner and Chef Workstation'),
      ('Nagios Monitoring: hosts the Nagios monitoring page'),
      ('node1: PostgreSQL'),
      ('node2: Flask App (you are here!)'),
      ('node3: Replica Backup Database')
    ON CONFLICT DO NOTHING;"
  EOH
  action :run
  only_if { node['db']['role'] == 'primary' }
end

bash 'grant_permissions' do
  user 'postgres'
  code <<-EOH
    psql -d fleetdb -c "GRANT ALL PRIVILEGES ON TABLE nodes TO fleetapp;"
  EOH
  action :run
  only_if { node['db']['role'] == 'primary' }
end

# Replication setup for Node 3 backup
bash 'configure_replication_primary' do
  user 'postgres'
  code <<-EOH
    psql -c "SELECT 1 FROM pg_roles WHERE rolname='replicator'" | grep -q 1 || \
      psql -c "CREATE USER replicator WITH REPLICATION PASSWORD 'replpass';"
  EOH
  action :run
end

template '/etc/postgresql/16/main/postgresql.conf' do
  source 'postgresql.conf.erb'
  owner 'postgres'
  group 'postgres'
  mode '0644'
  notifies :restart, 'service[postgresql]'
end

template '/etc/postgresql/16/main/pg_hba.conf' do
  source 'pg_hba.conf.erb'
  owner 'postgres'
  group 'postgres'
  mode '0640'
  notifies :restart, 'service[postgresql]'
end

# Perform regular backups -- once per hour
bash 'backup_cron' do
  code <<-EOH
    echo "0 * * * * postgres pg_dump fleetdb > /var/backups/fleetdb_$(date +%Y%m%d).sql" \
      > /etc/cron.d/fleetdb_backup
  EOH
  action :run
end