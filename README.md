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

    $ puppet apply node_gce/tests/uninstall.pp
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

# Usage

Puppet Face node_gce usage is similar to other cloud provisioner faces. It support the following list of actions:

    $ puppet help node_gce
    USAGE: puppet node_gce <action>
    
    This subcommand provides a command line interface to manage Google Compute
    machine instances.  We support creation of instances, shutdown of instances
    and basic queries for Google Compute data on a per-project basis.
    
    OPTIONS:
      --mode MODE                    - The run mode to use (user, agent, or master).
      --render-as FORMAT             - The rendering format to use.
      --verbose                      - Whether to log verbosely.
      --debug                        - Whether to log debug information.
    
    ACTIONS:
      create             Create a new machine instance.
      create_metadata    Create or update project metadata.
      disks              List disks.
      firewalls          List firewalls.
      images             List images.
      kernels            List kernels.
      list               List machine instances.
      metadata           List project metadata.
      networks           List networks.
      operations         List operations.
      project            Return information on the project in question.
      terminate          Destroy a running machine instance.
      zones              List zones.$ puppet help node_gce

Before creating any new instances, make sure the project metadata contains a ssh key. The sshkey metadata key is 'sshKeys' and the value is a list of ssh keys that's in the format of 'usenname:sshkey-type sshkey value' seperated by newlines.

    $ puppet node_gce create_metadata --project=puppetlabs.com:gce --key 'sshKeys' --value 'username:ssh-rsa AAAA..'
    $ puppet node_gce metadata --project=puppetlabs.com:gce
    {
     "kind": "compute#project",
     "id": "12797701871295264544",
     "creationTimestamp": "2012-06-20T19:56:41.970",
     "selfLink": "https://www.googleapis.com/compute/v1beta12/projects/puppetlabs.com:gce",
     "name": "puppetlabs.com:gce",
     "description": "",
     "commonInstanceMetadata": {
      "kind": "compute#metadata",
      "items": [
       {
        "key": "sshKeys",
        "value": "username:ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAg...",
       }
      ]
     },
     ...

To create new nodes:

    $ puppet node_gce create --name=demo1 --project=puppetlabs.com:gce
    {
     "kind": "compute#instance",
     "id": "12920446812432197392",
     "selfLink": "https://www.googleapis.com/compute/v1beta12/projects/puppetlabs.com:gce/instances/demo1",
     "name": "foo",
     "description": "",
     "image": "https://www.googleapis.com/compute/v1beta12/projects/google/images/ubuntu-12-04-v20120621",
     "machineType": "https://www.googleapis.com/compute/v1beta12/projects/puppetlabs.com:raiden/machine-types/n1-standard-1",
     "status": "PROVISIONING",
     "zone": "https://www.googleapis.com/compute/v1beta12/projects/puppetlabs.com:gce/zones/us-central1-a",
     "networkInterfaces": [
      {
       "kind": "compute#networkInterface",
       "name": "nic0",
       "network": "https://www.googleapis.com/compute/v1beta12/projects/puppetlabs.com:gce/networks/default",
       "networkIP": "10.240.20.171",
       "accessConfigs": [
        {
         "kind": "compute#accessConfig",
         "name": "External NAT",
         "type": "ONE_TO_ONE_NAT",
         "natIP": "173.255.112.192"
        }
       ]
      }
     ],
     "disks": [
      {
       "kind": "compute#attachedDisk",
       "type": "EPHEMERAL",
       "mode": "READ_WRITE",
       "index": 0
      }
     ]
    }

To ssh into the system after it's created provide the appropriate sshkey and login to the public IP address provided above:

    $ ssh -i ~/.ssh/private.rsa username@{ipaddress}

Note: when updating metadata sshkeys, new keys may take upwards of 60 sec to propogate.

Google recommends these additional parameters since compute nodes are ephemeral.

    $ ssh -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o StrictHostKeyChecking=no -i ~/.ssh/private.rsa -o LogLevel=QUIET -A -p 22 username@{ipaddress}

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
