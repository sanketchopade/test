#
# Cookbook Name:: nginx
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'nginx::default'

# Install nginx - in case server is newly build
package 'nginx'

# Create customised root location for our website
# can be used if server is newly build
directory "/var/html" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Stop nginix service
service 'nginx' do 
  supports [:status]
  action :stop
end

# Copy new code to landing directory /var/tmp
cookbook_file "/var/tmp/prj_01.zip" do
  source "prj_01.zip"
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

# Deploy new code
# we can also pull new code from git 
# we can also have functionality to compare checksum
bash 'install_app' do
  user 'root'
  cwd '/var/html'
  code <<-EOH
  zip -r /var/backup/prj_01.zip /var/html/
  rm -rf /var/html/*
  cd /var/html/
  unzip /var/tmp/prj_01.zip
  EOH
end

# Optional - if server is newly build
# Update nginx config file with customised parameters
template "/etc/nginx/conf.d/default.conf" do
  source "default.conf.erb"
  owner "root"
  group "root"
  mode 00600
  variables(:allow_override => "All")
end

# Optional - if server is newly build
# Update firewall to allow traffic on port 80
# Load firewall rules we know works
template "/etc/sysconfig/iptables" do
  source "iptables.erb"
  owner "root"
  group "root"
  mode 00600
  variables(:allow_override => "All")
  # notifies :restart, resources(:service => "iptables")
end

#restart iptables service
execute "service iptables restart" do
  user "root"
  command "service iptables restart"
end

#start nginix service
service 'nginx' do 
	supports [:status]
	action :start
end