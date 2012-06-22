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
* Execute bin/credentials_builder.rb specifying that output should go to ~/.fog (spec/fixtures/credentials.yml for testing)

        Building credentials file for Google Compute Oauth2
        Enter client_id: 583011575284-idaf812lkj3kda0f.apps.googleusercontent.com
        Enter client_secret: qbWsdfk8zkdasf123j
        
        Go to this link to authorize the application:
        
        https://accounts.google.com/o/oauth2/auth?scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2F
        ...
        
        and enter the code you find after authorizing: 4/sbQCOs8lkz8cvjq2k3-jvzafdsaf.
        
        client_id: 52313212-idasf921.apps.googleusercontent.com
        client_secret: ida8214kdasfsd93
        authorization_code: sfas1/daf9123123kjfasfojdjsfk213213
        refresh_token: dsfas9123kdsfaj123;sadkfa
        
        Enter file for storing OAuth2 credentials [/tmp/oauth2_credentials.yml]: ~/.fog
        Storing credentials information in [~/.fog]...

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

 - git clone and/or update checkouts of puppet, facter, and node_gce face.

        $ cd ~/src
        % git clone https://github.com/puppetlabs/puppet.git
        % git clone https://github.com/puppetlabs/facter.git
        % git clone https://github.com/puppetlabs/puppetlabs-node_gce.git

 - Verify puppet version 2.7.12+ and facter version 1.6.9+:

        % ENVPUPPET_BASEDIR=~/src; export ENVPUPPET_BASEDIR
        % . ~/src/puppet/ext/envpuppet
        % puppet --version
        % facter --version

 - Add node_gce/lib to RUBYLIB:

        % set +e
        % RUBYLIB="${RUBYLIB}:${HOME}/git/puppetlabs-node_gce/lib"; export RUBYLIB
        % gem install rspec mocha oauth

 - Execute bin/credentials_builder.rb and specify output file: spec/fixtures/credentials.yml
 - Create a spec/fixtures/project.yml with your project name in it (see spec/fixtures/project.yml-example).

        % rspec spec
