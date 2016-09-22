# encoding: UTF-8
if defined?(ChefSpec)
  def create_openstack_application_catalog_application(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :openstack_application_catalog_application,
      :create,
      resource_name)
  end
end
