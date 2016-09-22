# encoding: UTF-8
#
# Cookbook Name:: openstack-application-catalog
# Provider:: application
#
# Copyright 2016, Mirantis Inc.
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

include ::Openstack

use_inline_resources

action :create do
  @user = new_resource.identity_user
  @pass = new_resource.identity_pass
  @tenant = new_resource.identity_tenant
  @ks_uri = new_resource.identity_uri

  name = new_resource.name
  package_path = "/var/cache/murano/meta/#{name}.zip"
  category = new_resource.category ? new_resource.category : nil
  is_public = new_resource.is_public

  ep = public_endpoint 'application-catalog'
  @api = ep.to_s.gsub(ep.path, '') # remove trailing /v2

  _add_application(name, package_path, category, is_public)
  new_resource.updated_by_last_action(true)
end

action :destroy do
  # TODO
end

private

def _add_application(name, package_path, category, is_public)
  murano_cmd = "murano --insecure --os-username #{@user} --os-password #{@pass} --os-tenant-name #{@tenant} --murano-url #{@api} --os-auth-url #{@ks_uri}"
  murano_opts = ''
  murano_opts += '--is-public' if is_public
  murano_opts += "-C #{category}" if category
  execute "Adding #{name} application" do
    command "#{murano_cmd} package-import #{murano_opts} #{package_path}"
  end
end
