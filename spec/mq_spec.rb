# encoding: UTF-8

require_relative 'spec_helper'

describe 'openstack-application-catalog::server' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    include_context 'application-catalog-stubs'

    context 'custom mq attributes' do
      before do
        node.set['openstack']['mq']['compute']['rabbit']['userid'] = 'not-a-guest'
        node.set['openstack']['murano']['rabbit_own_vhost'] = '/foo'
      end

      it 'does not delete guest user' do
        expect(chef_run).not_to delete_rabbitmq_user(
          'remove rabbit guest user'
        ).with(user: 'guest')
      end

      it 'adds murano rabbit user' do
        expect(chef_run).to add_rabbitmq_user(
          'add murano rabbit user'
        ).with(user: 'not-a-guest', password: 'mq-pass')
      end

      it 'changes murano rabbit user password' do
        expect(chef_run).to change_password_rabbitmq_user(
          'change murano rabbit user password'
        ).with(user: 'not-a-guest', password: 'mq-pass')
      end

      it 'adds murano rabbit vhost' do
        expect(chef_run).to add_rabbitmq_vhost(
          'add murano rabbit vhost'
        ).with(vhost: '/foo')
      end

      it 'sets murano user permissions' do
        expect(chef_run).to set_permissions_rabbitmq_user(
          'set murano user permissions'
        ).with(user: 'not-a-guest', vhost: '/foo', permissions: '.* .* .*')
      end
    end
  end
end
