require 'puppet/face/node_gce'

Puppet::Face.define :node_gce, '0.0.1' do
  action :create do
    summary 'Create a new machine instance.'
    description <<-EOT
      Launches a new Google Compute machine instance and returns the
      machine's identifier.

      A newly created system may not be immediately ready after launch while
      it boots.
    EOT

    option '--project=' do
      summary 'The name of the Google Compute project.'

      description <<-EOT
        The name of the Google Compute project to query.
      EOT

      required
    end

    when_invoked do |options|
      Puppet::GoogleCompute.new(options[:project]).instance_create(options)
    end

    when_rendering :console do |value|
      value.to_s
    end
  end
end
