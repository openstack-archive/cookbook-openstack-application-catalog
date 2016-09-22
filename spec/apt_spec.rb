# encoding: UTF-8

require_relative 'spec_helper'

describe 'openstack-application-catalog::server' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    include_context 'application-catalog-stubs'

    it 'configures murano repository' do
      expect(chef_run).to add_apt_repository('murano_repo').with(
        key: 'http://mirror.fuel-infra.org/mos-repos/ubuntu/9.0/archive-mos9.0.key',
        uri: 'http://mirror.fuel-infra.org/mos-repos/ubuntu/9.0/',
        distribution: 'mos9.0',
        components: ['main'])
    end

    it 'installs the murano-api package' do
      expect(chef_run).to install_package 'murano-api'
    end

    it 'installs the murano-cfapi package' do
      expect(chef_run).to install_package 'murano-cfapi'
    end

    it 'installs the murano-common package' do
      expect(chef_run).to install_package 'murano-common'
    end

    it 'installs the murano-engine package' do
      expect(chef_run).to install_package 'murano-engine'
    end

    it 'installs the python-muranoclient package' do
      expect(chef_run).to install_package 'python-muranoclient'
    end

    it 'installs the murano-glance-artifacts-plugin package' do
      expect(chef_run).to install_package 'murano-glance-artifacts-plugin'
    end

    it 'installs the python-murano-dashboard package' do
      expect(chef_run).to install_package 'python-murano-dashboard'
    end

    it 'enables the murano-api service' do
      expect(chef_run).to enable_service('murano-api')
    end

    it 'enables the murano-cfapi service' do
      expect(chef_run).to enable_service('murano-cfapi')
    end

    it 'enables the murano-engine service' do
      expect(chef_run).to enable_service('murano-engine')
    end
  end
end
