# encoding: UTF-8
require 'chefspec'
require 'chefspec/berkshelf'

ChefSpec::Coverage.start! { add_filter 'openstack-application-catalog::server' }

require 'chef/application'

UBUNTU_OPTS = {
  platform: 'ubuntu',
  version: '16.04',
  log_level: :fatal
}.freeze

shared_context 'application-catalog-stubs' do
  before do
    stub_command('/usr/sbin/apache2 -t').and_return(true)
    stub_command("grep '^## MURANO_CONFIG_BEGIN' /etc/openstack-dashboard/local_settings.py").and_return(true)
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('db', 'murano')
      .and_return('murano-dbpass')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('service', 'openstack-application-catalog')
      .and_return('murano-pass')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'guest')
      .and_return('mq-pass')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'admin')
      .and_return('admin-pass')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('token', 'openstack_identity_bootstrap_token')
      .and_return('bootstrap-token')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('db', 'mysqlroot')
      .and_return('mysqlroot')
    allow(Chef::Application).to receive(:fatal!)
  end
end

shared_examples 'expect-runs-recipe' do
  it 'runs server recipe' do
    expect(chef_run).to include_recipe 'openstack-application-catalog::server'
  end
  it 'runs dashboard recipe' do
    expect(chef_run).to include_recipe 'openstack-application-catalog::dashboard'
  end
end
