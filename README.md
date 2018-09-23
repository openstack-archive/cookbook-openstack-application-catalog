Description
===========

This cookbook installs the OpenStack Application Catalog Service
**Murano** as part of the OpenStack reference deployment Chef for OpenStack. The
https://github.com/openstack/openstack-chef-repo contains documentation for
using this cookbook in the context of a full OpenStack deployment. Murano is
installed from packages, creating the default user, tenant, and roles. It also
registers the application-catalog service and application-catalog endpoint.

https://docs.openstack.org/murano/latest/

Requirements
============

- Chef 12 or higher
- chefdk 0.9.0 for testing (also includes berkshelf for cookbook dependency
  resolution)

Platform
========

- ubuntu

Cookbooks
=========

The following cookbooks are dependencies:

- openstack-common (>=14.0.0)
- openstack-identity (>=14.0.0)
- openstack-ops-messaging (>=14.0.0)
- 'openstackclient', '>= 0.1.0'
- apache2

Attributes
==========

Please see the extensive inline documentation in `attributes/*.rb` for
descriptions of all the settable attributes for this cookbook.

Note that all attributes are in the `default['openstack']` "namespace"

The usage of attributes to generate the murano.conf is decribed in the
openstack-common cookbook.

Providers
=========

application
-----

Action: `:create`

- `:name`: A name of the application.
- `:category`: Application category.
- `:is_public`: True/False - should application be public or user specific.
- `:identity_user`: Username of the Keystone admin user.
- `:identity_pass`: Password for the Keystone admin user.
- `:identity_tenant`: Name of the Keystone admin user's tenant.
- `:identity_uri`: URI of the Identity API endpoint.

Recipes
=======

## openstack-application-catalog::server
- Installs the Openstack application-catalog service

## openstack-application-catalog::dashboard
- Extends Horizon service to include Murano

## openstack-application-catalog::openrc
- Creates muranorc file


License and Author
==================

Author:: Damian Szeluga (<dszeluga@mirantis.com>)
Author:: Maciej Relewicz (<mrelewicz@mirantis.com>)

Copyright 2016, Mirantis Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
