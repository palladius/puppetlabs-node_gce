# Class: node_gce
#
# This module manages node_gce
#
# Parameters:
#  * optional: install optional gems.
#  * development: install development gems.
#  * provider: gem provider to use. (pe_gem or gem)
#
# Actions:
#  Installs puppet node_gce face and dependencies
#
# Requires:
#  * lib_puppet module.
#  * pe_gem module.
#
# Sample Usage:
#
#   class { 'node_gce':
#     ensure      => present,
#     optional    => true,
#     development => true,
#   }
class node_gce (
  $ensure       = present,
  $optional     = true,
  $development  = false,
  $provider     = $node_gce::params::provider
) inherits node_gce::params {

  package { 'oauth2':
    ensure   => $ensure,
    provider => $provider,
  }

  if $optional {
    package { ['json', 'system_timer']:
      ensure   => $ensure,
      provider => $provider,
    }
  }

  if $development {
    package { ['rspec', 'mocha']:
      ensure   => $ensure,
      provider => $provider,
    }
  }

  # This is to distribute face and work around #7316.
  # This is not expected to be necessary in Telly.
  lib_puppet { [ 'application/node_gce.rb',
                 'face/node_gce',
                 'face/node_gce.rb',
                 'google_compute.rb' ]:
    ensure  => $ensure,
    recurse => true,
  }
  file {'/tmp/build_gce_credentials.rb':
    mode    => 755,
    content => template('node_gce/build_gce_credentials.erb'),
  }
  notice("Creating /tmp/build_gce_credentials.rb")
}
