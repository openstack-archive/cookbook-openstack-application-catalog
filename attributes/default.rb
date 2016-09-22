# encoding: UTF-8
#
# Cookbook Name:: openstack-application-catalog
# Attributes:: default
#
# Copyright 2016, Mirantis Inc.
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

case node['platform_family']
when 'rhel'
  default['openstack']['murano'] = {
    'api_package_name'          => 'openstack-murano-api',
    'cfapi_package_name'        => 'openstack-murano-cfapi',
    'common_package_name'       => 'openstack-murano-common',
    'engine_package_name'       => 'openstack-murano-engine',
    'pythonclient_package_name' => 'openstack-python-muranoclient',
    'dashboard_package_name'    => 'openstack-murano-dashboard',
    'api_service_name'          => 'murano-api',
    'cfapi_service_name'        => 'murano-cfapi',
    'engine_service_name'       => 'murano-engine',
    'local_settings_path'       => '/etc/openstack-dashboard/local_settings',
    'pymysql_package_name'      => nil
  }
when 'debian'
  default['openstack']['murano'] = {
    'api_package_name'          => 'murano-api',
    'cfapi_package_name'        => 'murano-cfapi',
    'common_package_name'       => 'murano-common',
    'engine_package_name'       => 'murano-engine',
    'pythonclient_package_name' => 'python-muranoclient',
    'dashboard_package_name'    => 'python-murano-dashboard',
    'api_service_name'          => 'murano-api',
    'cfapi_service_name'        => 'murano-cfapi',
    'engine_service_name'       => 'murano-engine',
    'local_settings_path'       => '/etc/openstack-dashboard/local_settings.py',
    'pymysql_package_name'      => 'python-pymysql'
  }
end

%w(public internal admin).each do |type|
  default['openstack']['endpoints'][type]['application-catalog']['host'] = '127.0.0.1'
  default['openstack']['endpoints'][type]['application-catalog']['scheme'] = 'http'
  default['openstack']['endpoints'][type]['application-catalog']['port'] = '8082'
end

default['openstack']['murano']['apt_murano_repo'] = 'http://mirror.fuel-infra.org/mos-repos/ubuntu/9.0/'
default['openstack']['murano']['apt_murano_key'] = 'http://mirror.fuel-infra.org/mos-repos/ubuntu/9.0/archive-mos9.0.key'
default['openstack']['murano']['apt_murano_distribution'] = 'mos9.0'
default['openstack']['murano']['apt_murano_components'] = ['main']

default['openstack']['murano']['dbmanage_command'] = 'murano-db-manage --config-file /etc/murano/murano.conf upgrade'
default['openstack']['murano']['default_external_network'] = 'ext-net'
default['openstack']['murano']['tenant'] = 'services'
default['openstack']['murano']['auth_url'] = 'http://127.0.0.1:5000'
default['openstack']['murano']['cfapi_bind_port'] = 8083
default['openstack']['murano']['cfapi_bind_host'] = '127.0.0.1'
default['openstack']['murano']['engine_workers'] = nil
default['openstack']['murano']['db_name'] = 'murano'
default['openstack']['murano']['db_user'] = 'murano'
default['openstack']['murano']['package_ensure'] = 'present'
default['openstack']['murano']['verbose'] = true
default['openstack']['murano']['debug'] = false
default['openstack']['murano']['use_syslog'] = false
default['openstack']['murano']['use_stderr'] = false
default['openstack']['murano']['log_facility'] = nil
default['openstack']['murano']['log_dir'] = '/var/log/murano'
default['openstack']['murano']['data_dir'] = '/var/cache/murano'
default['openstack']['murano']['notification_driver'] = 'messagingv2'
default['openstack']['murano']['rabbit_ha_queues'] = nil
default['openstack']['murano']['rabbit_own_vhost'] = 'murano'
default['openstack']['murano']['service_host'] = '127.0.0.1'
default['openstack']['murano']['service_port'] = '8082'
default['openstack']['murano']['service_role'] = 'admin'
default['openstack']['murano']['region'] = 'RegionOne'
default['openstack']['murano']['default_log_levels'] = [
  'amqp=WARN',
  'amqplib=WARN',
  'boto=WARN',
  'iso8601=WARN',
  'keystonemiddleware=WARN',
  'oslo.messaging=INFO',
  'oslo_messaging=INFO',
  'qpid=WARN',
  'requests.packages.urllib3.connectionpool=WARN',
  'requests.packages.urllib3.util.retry=WARN',
  'routes.middleware=WARN',
  'sqlalchemy=WARN',
  'stevedore=WARN',
  'suds=INFO',
  'taskflow=WARN',
  'urllib3.connectionpool=WARN',
  'urllib3.util.retry=WARN',
  'websocket=WARN'
]
default['openstack']['murano']['use_ssl'] = false
default['openstack']['murano']['use_neutron'] = true
default['openstack']['murano']['use_trusts'] = true
default['openstack']['murano']['packages_service'] = 'murano'
default['openstack']['murano']['sync_db'] = true
# v3
default['openstakc']['murano']['conf']['keystone_authtoken']['auth_type'] = 'v3password'
default['openstack']['murano']['conf']['keystone_authtoken']['project_name'] = 'service'
default['openstack']['murano']['conf']['keystone_authtoken']['project_domain_name'] = 'Default'
default['openstack']['murano']['conf']['keystone_authtoken']['user_domain_name'] = 'Default'
# end of v3
default['openstack']['murano']['admin_user'] = 'murano'
default['openstack']['murano']['admin_tenant_name'] = 'service'
default['openstack']['murano']['auth_uri'] = 'http://127.0.0.1:5000'
default['openstack']['murano']['identity_uri'] = 'http://127.0.0.1:35357/'
default['openstack']['murano']['signing_dir'] = '/tmp/keystone-signing-muranoapi'
default['openstack']['murano']['cfapi_enabled'] = false
default['openstack']['murano']['dashboard_collect_static_script'] = '/usr/share/openstack-dashboard/manage.py'
default['openstack']['murano']['dashboard_metadata_dir'] = '/var/cache/murano-dashboard'
default['openstack']['murano']['dashboard_max_file_size'] = '5'
default['openstack']['murano']['dashboard_debug_level'] = 'DEBUG'
default['openstack']['murano']['dashboard_client_debug_level'] = 'ERROR'
default['openstack']['murano']['dashboard_sync_db'] = false
default['openstack']['murano']['app_catalog_ui'] = false
default['openstack']['murano']['dashboard_apache_user'] = 'horizon'
default['openstack']['murano']['dashboard_apache_group'] = 'horizon'
default['openstack']['murano']['openrc_path'] = '/root'
default['openstack']['murano']['openrc_path_mode'] = '0700'
default['openstack']['murano']['openrc_file'] = 'muranorc'
default['openstack']['murano']['openrc_file_mode'] = '0600'
default['openstack']['murano']['openrc_user'] = 'root'
default['openstack']['murano']['openrc_group'] = 'root'
default['openstack']['murano']['openrc_repo_url'] = 'http://storage.apps.openstack.org/'
default['openstack']['murano']['cert_file'] = nil
default['openstack']['murano']['key_file'] = nil
default['openstack']['murano']['ca_file'] = nil
default['openstack']['murano']['external_network'] = nil
default['openstack']['murano']['default_router'] = 'murano-default-router'
default['openstack']['murano']['default_nameservers'] = '8.8.8.8'
default['openstack']['murano']['database_connection'] = nil
default['openstack']['murano']['database_idle_timeout'] = nil
default['openstack']['murano']['database_min_pool_size'] = nil
default['openstack']['murano']['database_max_pool_size'] = nil
default['openstack']['murano']['database_max_retries'] = nil
default['openstack']['murano']['database_retry_interval'] = nil
default['openstack']['murano']['database_max_overflow'] = nil
default['openstack']['murano']['dashboard_repo_url'] = nil
default['openstack']['murano']['dashboard_api_url'] = nil
if default['openstack']['murano']['use_ssl']
  unless default['openstack']['murano']['cert_file'] & default['openstack']['murano']['key_file'] & default['openstack']['murano']['ca_file']
    raise 'cert_file, key_file and ca_file parameters must be set when use_ssl is set to true'
  end
end
if default['openstack']['murano']['use_neutron']
  unless default['openstack']['murano']['default_router']
    raise 'The default_router parameter is required when use_neutron is set to true'
  end
end
default['openstack']['murano']['glare'] = if default['openstack']['murano']['packages_service'] == 'glance'
                                            false
                                          else
                                            true
                                          end
# Config
default['openstack']['murano']['conf'].tap do |conf|
  conf['networking']['create_router'] = default['openstack']['murano']['use_neutron']
  conf['networking']['default_dns'] = default['openstack']['murano']['default_nameservers']
  if default['openstack']['murano']['use_neutron']
    conf['networking']['router_name'] = default['openstack']['murano']['default_router']
    conf['networking']['external_network'] = default['openstack']['murano']['external_network']
  end
  if default['openstack']['murano']['use_ssl']
    %w(cert_file ca_file key_file).each do |ssl_file|
      conf['ssl'][ssl_file] = default['openstack']['murano'][ssl_file]
    end
  end
  conf['murano']['url'] = if default['openstack']['murano']['use_ssl']
                            "https://#{default['openstack']['murano']['service_host']}:#{default['openstack']['murano']['service_port']}"
                          else
                            "http://#{default['openstack']['murano']['service_host']}:#{default['openstack']['murano']['service_port']}"
                          end
  conf['engine']['use_trusts'] = default['openstack']['murano']['use_trusts']
  conf['rabbitmq']['login'] = default['openstack']['mq']['compute']['rabbit']['userid']
  conf['keystone_authtoken']['auth_uri'] = default['openstack']['murano']['auth_uri']
  conf['keystone_authtoken']['admin_user'] = default['openstack']['murano']['admin_user']
  conf['keystone_authtoken']['admin_tenant_name'] = default['openstack']['murano']['admin_tenant_name']
  conf['keystone_authtoken']['signing_dir'] = default['openstack']['murano']['signing_dir']
  conf['keystone_authtoken']['identity_uri'] = default['openstack']['murano']['identity_uri']
  conf['packages_opts']['packages_service'] = default['openstack']['murano']['packages_service']
  conf['DEFAULT']['notification_driver'] = default['openstack']['murano']['notification_driver']
  conf['DEFAULT']['rabbit_userid'] = default['openstack']['mq']['compute']['rabbit']['userid']
  conf['DEFAULT']['debug'] = default['openstack']['murano']['debug']
  conf['DEFAULT']['verbose'] = default['openstack']['murano']['verbose']
  conf['DEFAULT']['use_stderr'] = default['openstack']['murano']['use_stderr']
  conf['DEFAULT']['use_syslog'] = default['openstack']['murano']['use_syslog']
  conf['DEFAULT']['log_dir'] = default['openstack']['murano']['log_dir']
  if default['openstack']['murano']['use_syslog']
    conf['DEFAULT']['syslog_log_facility'] = default['openstack']['murano']['log_facility']
  end
  conf['DEFAULT']['default_log_levels'] = default['openstack']['murano']['default_log_levels'].join(',')
  conf['DEFAULT']['bind_host'] = default['openstack']['murano']['service_host']
  conf['DEFAULT']['bind_port'] = default['openstack']['murano']['service_port']
  if default['openstack']['murano']['cfapi_enabled']
    conf['cfapi']['tenant'] = default['openstack']['murano']['tenant']
    conf['cfapi']['auth_uri'] = default['openstack']['murano']['auth_url']
    conf['cfapi']['bind_host'] = default['openstack']['murano']['cfapi_bind_host']
    conf['cfapi']['bind_port'] = default['openstack']['murano']['cfapi_bind_port']
  end
  if default['openstack']['murano']['engine_workers']
    conf['engine']['workers'] = default['openstack']['murano']['engine_workers']
  end
  if default['openstack']['murano']['database_idle_timeout']
    conf['database']['idle_timeout'] = default['openstack']['murano']['database_idle_timeout']
  end
  if default['openstack']['murano']['database_min_pool_size']
    conf['database']['min_pool_size'] = default['openstack']['murano']['database_min_pool_size']
  end
  if default['openstack']['murano']['database_max_retries']
    conf['database']['max_retries'] = default['openstack']['murano']['database_max_retries']
  end
  if default['openstack']['murano']['database_retry_interval']
    conf['database']['retry_interval'] = default['openstack']['murano']['database_retry_interval']
  end
  if default['openstack']['murano']['database_max_pool_size']
    conf['database']['max_pool_size'] = default['openstack']['murano']['database_max_pool_size']
  end
  if default['openstack']['murano']['database_max_overflow']
    conf['database']['max_overflow'] = default['openstack']['murano']['database_max_overflow']
  end
end
