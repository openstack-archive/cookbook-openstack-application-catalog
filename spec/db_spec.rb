# encoding: UTF-8

require_relative 'spec_helper'

describe 'openstack-application-catalog::server' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    include_context 'application-catalog-stubs'

    it 'create mysql database' do
      expect(chef_run).to create_mysql_database('murano')
    end

    it 'create mysql user' do
      expect(chef_run).to grant_mysql_database_user('murano')
    end
  end
end
