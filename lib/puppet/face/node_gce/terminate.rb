require 'puppet/face/node_gce'

Puppet::Face.define :node_gce, '0.0.1' do
  action :terminate do
    summary 'Destroy a running machine instance.'
    description <<-EOT
      Shuts down a new Google Compute machine instance and returns the
      machine's identifier.
    EOT

    option '--project=' do
      summary 'The name of the Google Compute project.'

      description <<-EOT
        The name of the Google Compute project to query.
      EOT

      required
    end

    option '--name=' do
      summary 'The name of the instance.'

      description <<-EOT
        The name of the Google Compute instance to terminate.
      EOT

      required
    end

    when_invoked do |options|
      Puppet::GoogleCompute.new(options[:project]).instance_delete(options)
    end

    when_rendering :console do |value|
      value.to_s
    end
  end
end
