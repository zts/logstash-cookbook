#
# Cookbook Name:: logstash
# Recipe:: client
#
# Copyright 2011, Zachary Stevens
# Copyright 2011, Joshua Timberman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "java"

directory node['logstash']['install_path'] do
  owner "nobody"
  group "nobody"
end

template "/etc/init.d/logstash" do
  source "logstash.init.erb"
  owner  "root"
  group  "root"
  mode   "755"
  variables ({
               "config_file" => "client.conf",
               "extra_options" => ""
             })
end

remote_file "#{node['logstash']['install_path']}/logstash-monolithic.jar" do
  source "#{node['logstash']['source_path']}/logstash-#{node['logstash']['version']}-monolithic.jar"
  owner "nobody"
  group "nobody"
  checksum node['logstash']['checksum']
  notifies :restart, "service[logstash]"
end

logstash_input "syslogs" do
  kind 'file'
  type 'syslog'
  path ['/var/log/messages', '/var/log/secure', '/var/log/*.log']
end
logstash_input "apache-access" do
  kind 'file'
  type 'apache-access'
  path '/var/log/httpd/access.log'
end
logstash_input "apache-error" do
  kind 'file'
  type 'apache-error'
  path '/var/log/httpd/error.log'
end

logstash_input "mcollective.log" do
  kind 'file'
  type 'mcollective'
  path '/var/log/mcollective.log'
end
logstash_input "mcollective-audit.log" do
  kind 'file'
  type 'mcollective-audit'
  path '/var/log/mcollective-audit.log'
end
logstash_filter "mcollective" do
  kind 'multiline'
  type 'mcollective'
  pattern '^\s'
  what 'previous'
end

service "logstash" do
  # supports :restart => true, :status => true
  action [:enable, :start]
end

