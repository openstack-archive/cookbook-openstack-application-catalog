name 'openstack-application-catalog'
maintainer 'openstack-chef'
maintainer_email 'openstack-discuss@lists.openstack.org'
issues_url 'https://launchpad.net/openstack-chef' if respond_to?(:issues_url)
source_url 'https://github.com/openstack/cookbook-openstack-application-catalog' if respond_to?(:source_url)
license 'Apache 2.0'
description 'Installs/Configures openstack-application-catalog'
long_description 'Installs/Configures openstack-application-catalog'
version '0.1.0'

supports 'ubuntu'

depends 'openstack-common', '>= 14.0.0'
depends 'openstack-identity', '>= 14.0.0'
depends 'openstack-ops-messaging', '>= 14.0.0'
depends 'openstackclient'
depends 'apache2'
