# Cookbook Name:: openstack-application-catalog
# Recipe:: server
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

apt_repository 'murano_repo' do
  uri          node['openstack']['murano']['apt_murano_repo']
  distribution node['openstack']['murano']['apt_murano_distribution']
  components   node['openstack']['murano']['apt_murano_components']
  key          node['openstack']['murano']['apt_murano_key']
  action :add
end

# temporary until CR-25599 is published
apt_repository 'murano_temp_repo' do
  uri          'http://perestroika-repo-tst.infra.mirantis.net/mos-repos/ubuntu/9.0/'
  distribution 'mos9.0-proposed'
  components   node['openstack']['murano']['apt_murano_components']
  key          node['openstack']['murano']['apt_murano_key']
  action :add
end

apt_preference 'pin_murano_repo_other_temp' do
  glob         '*'
  pin          'origin perestroika-repo-tst.infra.mirantis.net'
  pin_priority '-1'
end

apt_preference 'pin_murano_repo_temp' do
  glob         'python-murano-dashboard'
  pin          'origin perestroika-repo-tst.infra.mirantis.net'
  pin_priority '1200'
end
# end of temporary fix

packages = %w(api_package_name cfapi_package_name common_package_name
              engine_package_name pythonclient_package_name)

if node['openstack']['murano']['database_connection'] =~ /^mysql\+pymysql/
  packages << 'pymysql_package_name'
end

apt_preference 'pin_murano_repo' do
  glob         'murano-glance-artifacts-plugin python-django-formtools python-django-babel murano-api murano-cfapi murano-common murano-engine python-murano python-muranoclient init-system-helpers'
  pin          'origin mirror.fuel-infra.org'
  pin_priority '1200'
end

apt_preference 'pin_murano_repo_other' do
  glob         '*'
  pin          'origin mirror.fuel-infra.org'
  pin_priority '-1'
end

packages.each do |pkg|
  package node['openstack']['murano'][pkg] do
    action :install
  end
end

# config

db_password = get_password 'db', 'murano'
db_user = node['openstack']['murano']['db_user']
db_name = node['openstack']['murano']['db_name']
db_connection = db_uri('application-catalog', db_user, db_password)

user = node['openstack']['mq']['network']['rabbit']['userid']
node.default['openstack']['murano']['conf_secrets']
.[]('DEFAULT')['rabbit_password'] =
  get_password 'user', user
node.default['openstack']['murano']['conf_secrets']
.[]('rabbitmq')['password'] =
  get_password 'user', user
node.default['openstack']['murano']['conf_secrets']
.[]('keystone_authtoken')['admin_password'] =
  get_password 'user', 'admin'

node.default['openstack']['murano']['conf']
.[]('database')['connection'] = db_connection

murano_conf_options = merge_config_options 'murano'

directory '/etc/murano' do
  mode 00755
  action :create
end

directory '/var/log/murano' do
  mode 00755
  owner 'murano'
  group 'murano'
  action :create
end

template '/etc/murano/murano.conf' do
  source 'openstack-service.conf.erb'
  cookbook 'openstack-common'
  owner 'murano'
  group 'murano'
  mode 00640
  variables(
    service_config: murano_conf_options
  )
end

file '/etc/murano/murano-paste.ini' do
  mode 00644
end

file '/etc/murano/policy.json' do
  mode 00644
end

service 'murano-api' do
  supports restart: true, reload: true
  action :enable
end

service 'murano-cfapi' do
  supports restart: true, reload: true
  action :enable
end

service 'murano-engine' do
  supports restart: true, reload: true
  action :enable
end

bind_db = node['openstack']['bind_service']['db']
if bind_db['interface']
  listen_address = address_for bind_db['interface']
else
  listen_address = bind_db['host']
end

super_password = get_password 'db', node['openstack']['db']['root_user_key']

if node['openstack']['db']['service_type'] == 'mysql'

  # Create a sql server database
  mysql_database db_name do
    connection(
      host:     listen_address,
      port:     bind_db.port.to_s,
      username: 'root',
      password: super_password,
      options:  { 'CHARSET' => 'utf8', 'COLLATE' => 'utf8_general_ci' }
    )
    action :create
  end

  # Create user
  mysql_database_user db_user do
    connection(
      host:     listen_address,
      username: 'root',
      password: super_password
    )
    password      db_password
    database_name db_name
    privileges    [:all]
    action        :grant
    host          '%'
  end

end

if node['openstack']['db']['service_type'] == 'postgresql'
  # postgresql database backend has not been tested.
  # patches are welcome

  postgresql_connection_info = {
    host:     listen_address,
    port:     node['postgresql']['config']['port'],
    username: 'postgres',
    password: node['postgresql']['password']['postgres']
  }

  # Create user
  postgresql_database_user db_user do
    connection postgresql_connection_info
    password   super_password
    action     :create
  end

  # Create a postgress server database
  postgresql_database db_name do
    connection(
      host:     listen_addres,
      port:     bind_db.port.to_s,
      username: 'root',
      password: super_password
    )
    action :create
  end

  postgresql_database_user db_user do
    connection    postgresql_connection_info
    database_name db_name
    privileges    [:all]
    action        :grant
  end
end

include_recipe 'openstack-application-catalog::dashboard'

execute 'murano-dbmanage' do
  command node['openstack']['murano']['dbmanage_command']
  user 'murano'
  notifies :restart, 'service[murano-api]', :immediately
  notifies :restart, 'service[murano-cfapi]', :immediately
  notifies :restart, 'service[murano-engine]', :immediately
end

rabbitmq_user 'remove rabbit guest user' do
  user 'guest'
  action :delete
  not_if { user == 'guest' }
end

rabbitmq_user 'add murano rabbit user' do
  user node['openstack']['mq']['compute']['rabbit']['userid']
  password node['openstack']['murano']['conf_secrets']['rabbitmq']['password']
  action :add
end

rabbitmq_user 'change murano rabbit user password' do
  user node['openstack']['mq']['compute']['rabbit']['userid']
  password node['openstack']['murano']['conf_secrets']['rabbitmq']['password']
  action :change_password
end

rabbitmq_vhost 'add murano rabbit vhost' do
  vhost node['openstack']['murano']['rabbit_own_vhost']
  action :add
end

rabbitmq_user 'set murano user permissions' do
  user node['openstack']['mq']['compute']['rabbit']['userid']
  vhost node['openstack']['murano']['rabbit_own_vhost']
  permissions '.* .* .*'
  action :set_permissions
end

ie = public_endpoint 'identity'
ae = admin_endpoint 'identity'
ine = internal_endpoint 'identity'
auth_uri = ::URI.decode ae.to_s

murano_port = node['openstack']['murano']['service_port']

public_murano_api_endpoint = "#{ie.scheme}://#{ie.host}:#{murano_port}/"
admin_murano_api_endpoint = "#{ae.scheme}://#{ae.host}:#{murano_port}/"
internal_murano_api_endpoint = "#{ine.scheme}://#{ine.host}:#{murano_port}/"

service_pass = get_password 'service', 'openstack-application-catalog'
service_project_name = node['openstack']['murano']['conf']['keystone_authtoken']['project_name']
service_domain_name = node['openstack']['murano']['conf']['keystone_authtoken']['user_domain_name']
admin_user = node['openstack']['identity']['admin_user']
admin_pass = get_password 'user', node['openstack']['identity']['admin_user']
admin_project = node['openstack']['identity']['admin_project']
admin_domain = node['openstack']['identity']['admin_domain_name']
service_user = node['openstack']['murano']['admin_user']
service_role = node['openstack']['murano']['service_role']
region = node['openstack']['region']
murano_service_name = 'murano'
murano_service_type = 'application-catalog'
cfapi_service_name = 'murano-cfapi'
cfapi_service_type = 'service-broker'

connection_params = {
  openstack_auth_url:     "#{auth_uri}/auth/tokens",
  openstack_username:     admin_user,
  openstack_api_key:      admin_pass,
  openstack_project_name: admin_project,
  openstack_domain_name:    admin_domain
}

# Register Service Tenant
openstack_project service_project_name do
  connection_params connection_params
end

# Register Murano Service
openstack_service murano_service_name do
  type murano_service_type
  connection_params connection_params
end

# Register Murano Public-Endpoint
openstack_endpoint murano_service_type do
  service_name murano_service_name
  interface 'public'
  url ::URI.decode public_murano_api_endpoint.to_s
  region region
  connection_params connection_params
end

# Register Murano Internal-Endpoint
openstack_endpoint murano_service_type do
  service_name murano_service_name
  url ::URI.decode internal_murano_api_endpoint.to_s
  region region
  connection_params connection_params
end

# Register Murano Admin-Endpoint
openstack_endpoint murano_service_type do
  service_name murano_service_name
  interface 'admin'
  url ::URI.decode admin_murano_api_endpoint.to_s
  region region
  connection_params connection_params
end

# Register Service User
openstack_user service_user do
  project_name service_project_name
  role_name service_role
  password service_pass
  connection_params connection_params
end

## Grant Service role to Service User for Service Tenant ##
openstack_user service_user do
  role_name service_role
  project_name service_project_name
  connection_params connection_params
  action :grant_role
end

openstack_user service_user do
  domain_name service_domain_name
  role_name service_role
  user_name service_user
  connection_params connection_params
  action :grant_domain
end

if node['openstack']['murano']['cfapi_enabled']
  public_cfapi_api_endpoint = "#{ie.scheme}://#{ie.host}:8083/"
  admin_cfapi_api_endpoint = "#{ae.scheme}://#{ae.host}:8083/"
  internal_cfapi_api_endpoint = "#{ine.scheme}://#{ine.host}:8083/"

  # Register CFAPI Service
  openstack_service cfapi_service_name do
    type cfapi_service_type
    connection_params connection_params
  end

  # Register CFAPI Public-Endpoint
  openstack_endpoint cfapi_service_type do
    service_name cfapi_service_name
    interface 'public'
    url ::URI.decode public_cfapi_api_endpoint.to_s
    region region
    connection_params connection_params
  end

  # Register CFAPI Internal-Endpoint
  openstack_endpoint cfapi_service_type do
    service_name cfapi_service_name
    url ::URI.decode internal_cfapi_api_endpoint.to_s
    region region
    connection_params connection_params
  end

  # Register CFAPI Admin-Endpoint
  openstack_endpoint cfapi_service_type do
    service_name cfapi_service_name
    interface 'admin'
    url ::URI.decode admin_cfapi_api_endpoint.to_s
    region region
    connection_params connection_params
  end
end

openstack_application_catalog_application 'io.murano' do
  identity_user node['openstack']['murano']['admin_user']
  identity_pass service_pass
  identity_tenant service_project_name
  identity_uri auth_uri
  is_public true
  action :create
end
