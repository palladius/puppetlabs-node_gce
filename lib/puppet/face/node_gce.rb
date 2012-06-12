require 'puppet/face'
require 'puppet/google_compute'

Puppet::Face.define(:node_gce, '0.0.1') do
  copyright "Puppet Labs", 2012
  license   "Apache 2 license; see COPYING"

  summary "View and manage Google Compute nodes."
  description <<-'EOT'
    This subcommand provides a command line interface to manage Google Compute
    machine instances.  We support creation of instances, shutdown of instances
    and basic queries for Google Compute data on a per-project basis.
  EOT
end
