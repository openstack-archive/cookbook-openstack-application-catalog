# encoding: UTF-8

require_relative 'spec_helper'

describe 'openstack-application-catalog::dashboard' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    include_context 'application-catalog-stubs'

    describe '/etc/openstack-dashboard/local_settings.py' do
      let(:file) { chef_run.template('/etc/openstack-dashboard/local_settings.py') }

      it 'creates local_settings.py' do
        expect(chef_run).to create_template(file.name).with(
          user: 'root',
          group: 'root',
          mode: 00440
        )
      end
    end

    describe 'openstack-dashboard' do
      cmd = '/usr/share/openstack-dashboard/manage.py'
      cmd_environment = {
        'APACHE_USER' => 'horizon',
        'APACHE_GROUP' => 'horizon'
      }
      clean_cmd = "sed -e '/^## MURANO_CONFIG_BEGIN/,/^## MURANO_CONFIG_END ##/ d' -i /etc/openstack-dashboard/local_settings.py"

      it 'cleans horizon config' do
        expect(chef_run).to run_execute(clean_cmd)
      end

      it 'runs collectstatic' do
        expect(chef_run).to run_execute("#{cmd} collectstatic --noinput").with(
          environment: cmd_environment
        )
      end

      it 'runs compress' do
        expect(chef_run).to run_execute("#{cmd} compress --force").with(
          environment: cmd_environment
        )
      end
    end
  end
end
