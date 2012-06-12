require 'puppet/face/node_gce'

Puppet::Face.define :node_gce, '0.0.1' do

  action :create do

    summary 'Create a new machine instance.'
    description <<-EOT
      Launches a new Google Compute machine instance and returns the
      machine's identifier.

      A newly created system may not be immediately ready after launch while
      it boots.

      If creation of the instance fails, Puppet will automatically clean up
      after itself and tear down the instance.
    EOT

    when_invoked do |options|

    end
  end
end
