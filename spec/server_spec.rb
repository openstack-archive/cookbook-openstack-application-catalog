# encoding: UTF-8

require_relative 'spec_helper'

describe 'openstack-application-catalog::server' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS.merge(step_into: ['openstack_application_catalog_application'])) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    include_context 'application-catalog-stubs'

    describe 'server' do
      cmd = 'murano-db-manage --config-file /etc/murano/murano.conf upgrade'
      it 'runs dbmanage' do
        expect(chef_run).to run_execute(cmd).with(
          user: 'murano'
        )
      end

      it 'imports io.murano package' do
        expect(chef_run).to create_openstack_application_catalog_application('io.murano')
      end

      it 'adds io.murano application' do
        expect(chef_run).to run_execute('Adding io.murano application')
      end
    end
  end
end
