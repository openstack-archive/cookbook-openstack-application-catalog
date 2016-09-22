# Cookbook Name:: openstack-application-catalog
# Recipe:: dashboard
#
# Copyright (c) 2016 Mirantis Inc, All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'uri'
class ::Chef::Recipe
  include ::Openstack
end

if node['openstack']['murano']['glare']
  package 'murano-glance-artifacts-plugin' do
    action :install
  end
end

if node['openstack']['murano']['app_catalog_ui']
  package 'python-app-catalog-ui' do
    action :install
  end
end

package 'python-murano-dashboard'

include_recipe 'apache2'

template node['openstack']['murano']['local_settings_path'] do
  source 'local_settings.py.erb'
  mode 00440
  owner 'root'
  group 'root'
  variables(
    api_url: node['openstack']['murano']['dashboard_api_url'],
    repo_url: node['openstack']['murano']['dashboard_repo_url'],
    max_file_size: node['openstack']['murano']['dashboard_max_file_size'],
    metadata_dir: node['openstack']['murano']['dashboard_metadata_dir'],
    dashboard_debug_level: node['openstack']['murano']['dashboard_debug_level'],
    client_debug_level: node['openstack']['murano']['dashboard_client_debug_level'],
    enable_glare: node['openstack']['murano']['glare'],
    compress_offline: true
  )
end

dashboard_user = node['openstack']['murano']['dashboard_apache_user']
dashboard_group = node['openstack']['murano']['dashboard_apache_group']

execute 'clean_horizon_config' do
  command "sed -e '/^## MURANO_CONFIG_BEGIN/,/^## MURANO_CONFIG_END ##/ d' -i #{node['openstack']['murano']['local_settings_path']}"
  only_if "grep '^## MURANO_CONFIG_BEGIN' #{node['openstack']['murano']['local_settings_path']}"
end

execute 'django_collectstatic' do
  command "#{node['openstack']['murano']['dashboard_collect_static_script']} collectstatic --noinput"
  environment ({
    'APACHE_USER'  => dashboard_user,
    'APACHE_GROUP' => dashboard_group
  })
end

execute 'django_compressstatic' do
  command "#{node['openstack']['murano']['dashboard_collect_static_script']} compress --force"
  environment ({
    'APACHE_USER'  => dashboard_user,
    'APACHE_GROUP' => dashboard_group
  })
  notifies :reload, 'service[apache2]', :immediately
end
