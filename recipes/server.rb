#
# Cookbook Name:: logstash
# Recipe:: server
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

%w{tokyocabinet libevent grok}.each do |pkg|
  package pkg
end

directory node['logstash']['install_path'] do
  owner "nobody"
  group "nobody"
end

extra_opts = "-- web "
if node['logstash']['elasticsearch'] == 'embedded'
  extra_opts << "--backend elasticsearch:///?local"
elsif node['logstash']['elasticsearch'] == 'standalone'
  extra_opts << "--backend elasticsearch://#{node['logstash']['es_host']}/"
end
template "/etc/init.d/logstash" do
  source "logstash.init.erb"
  owner  "root"
  group  "root"
  mode   "755"
  variables ({
               "config_file" => "server.conf",
               "extra_options" => extra_opts
             })
end

remote_file "#{node['logstash']['install_path']}/logstash-monolithic.jar" do
  source "#{node['logstash']['source_path']}/logstash-#{node['logstash']['version']}-monolithic.jar"
  owner "nobody"
  group "nobody"
  checksum node['logstash']['checksum']
  notifies :restart, "service[logstash]"
end

template "#{node['logstash']['install_path']}/server.conf" do
  source "server.conf.erb"
  owner "nobody"
  group "nobody"
  notifies :restart, "service[logstash]"
end

service "logstash" do
  # supports :restart => true, :status => true
  action [:enable, :start]
end

