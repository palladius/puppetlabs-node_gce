require 'puppet/face/node_gce'

Puppet::Face.define :node_gce, '0.0.1' do
  action :list do
    summary 'List machine instances.'
    description <<-EOT
      Obtains a list of running machine instances and displays them on the
      console.
    EOT

    option '--project=' do
      summary 'The name of the Google Compute project.'

      description <<-EOT
        The name of the Google Compute project to query.
      EOT

      required
    end

    option '--name=' do
      summary 'The name of a specific Google Compute instance.'

      description <<-EOT
        The name of the Google Compute instance to query.
      EOT

    end

    when_invoked do |options|
      if :name
        Puppet::GoogleCompute.new(options[:project]).instance_get(options)
      else
        Puppet::GoogleCompute.new(options[:project]).instance_list
      end
    end

    when_rendering :console do |value|
      value.to_s
    end
  end
end
