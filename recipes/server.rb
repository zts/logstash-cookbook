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

directory node['logstash']['install_path'] do
  owner "nobody"
  group "nogroup"
end

cookbook_file "/etc/init.d/logstash" do
  source "logstash.init"
  owner  "root"
  group  "root"
  mode   "755"
end

cookbook_file "#{node['logstash']['install_path']}/logstash-monolithic.jar" do
  source "#{node['logstash']['source_path']}/logstash-#{node['logstash']['version']}-monolithic.jar"
  owner "nobody"
  group "nogroup"
  checksum node['logstash']['checksum']
  notifies :restart, "service[logstash-agent]"
  notifies :restart, "service[logstash-web]"
end

template "#{node['logstash']['install_path']}/agent.conf" do
  source "agent.conf.erb"
  owner "nobody"
  group "nogroup"
  notifies :restart, "service[logstash-agent]"
end

runit_service "logstash-agent"
runit_service "logstash-web"
