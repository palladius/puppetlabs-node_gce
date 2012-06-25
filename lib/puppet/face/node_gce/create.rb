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

    option '--name=' do
      summary 'The name of the instance.'

      description <<-EOT
        The name of the Google Compute instance to create.
      EOT

      required
    end

    option '--machine-type=' do
      summary 'The type of machine to create.'

      description <<-EOT
        The Google Compute machine type to create.  Defaults to "standard-1-cpu-ephemeral-disk".
      EOT
    end

    option '--zone=' do
      summary 'The zone in which to create the instance.'

      description <<-EOT
        The Google Compute zone to use when creating the instance.  Defaults to "us-east-a".
      EOT
    end

    option '--image=' do
      summary 'The image used to create the instance.'

      description <<-EOT
        The Google Compute image  to use when creating the instance.  Defaults to "".
      EOT
    end

    when_invoked do |options|
      Puppet::GoogleCompute.new(options[:project]).instance_create(options)
    end

    when_rendering :console do |value|
      value.to_s
    end
  end
end
