# puppetlabs node_gce module

This module provides a cloud provisioner face for google compute.

# Dependencies:

The puppet module tool in Puppet Enterprise 2.5.0+ and Puppet 2.7.14+ resolves dependencies automatically.

puppet module dependencies:

* puppetlabs-lib_puppet
* puppetlabs-pe_gem

node_gce also depends on the following gem (which are installed by the module):

* oauth2
* json (optional)
* system_timer (optional)
* rspec (dev only)
* mocha (dev only)

# Installation:

Install puppetlabs-node_gce module and dependencies into module_path:

    $ puppet module install puppetlabs-node_gce
    Preparing to install into /etc/puppet/modules ...
    Downloading from http://forge.puppetlabs.com ...
    Installing -- do not interrupt ...
    /etc/puppet/modules
    └─┬ puppetlabs-node_gce (v0.0.1)
      ├── puppetlabs-lib_puppet (v0.0.1)
      └── puppetlabs-pe_gem (v0.0.1)

For users, apply either init or minimal manifest:

    $ puppet apply node_gce/tests/init.pp

For developers of the puppet face, apply dev manifest:

    $ puppet apply node_gce/tests/dev.pp

# Uninstall:

The uninstall manifests should remove all gems and node_gce lib files from puppet:

    $ puppet apply node_gce/tests/init.pp
    $ puppet module uninstall puppetlabs-node_gce

# Configuration:

Usage of google compute project requires access to a project domain and a unique project id.

* Enable Google Compute Engine under Google API services.
* Create a Google Compute project domain and project id. (i.e. puppetlabs.com:my_project)
* Create a product name and authorize API access (project name: "Puppet Cloud Provisioner")
* Create a 'Client ID for an "installed application"'
* run bin/credentials_builder.rb specifying that output should go to ~/.fog (spec/fixtures/credentials.yml for testing)

Example ~/.fog configuration:

    :gce:
      :client_id: "52313212-idasf921.apps.googleusercontent.com"
      :client_secret: "ida8214kdasfsd93"
      :authorization_code: "sfas1/daf9123123kjfasfojdjsfk213213"
      :refresh_token: "dsfas9123kdsfaj123;sadkfa"

# Developers

To get your environment setup to be able to run specs:

 - clone and/or update git checkouts of puppet and facter
 - switch to puppet branch 2.7.12
 - switch to facter branch 1.6.9

    % ENVPUPPET_BASEDIR=~/git; export ENVPUPPET_BASEDIR
    % . ~/git/puppet/ext/envpuppet
    % set +e
    % RUBYLIB="${RUBYLIB}:${HOME}/git/puppetlabs-node_gce/lib"; export RUBYLIB
    % gem install rspec mocha oauth

 - run bin/credentials_builder.rb specifying that output should go to spec/fixtures/credentials.yml
 - make a spec/fixtures/project.yml (see spec/fixtures/project.yml-example for format) with your project name in it

    % rspec spec
