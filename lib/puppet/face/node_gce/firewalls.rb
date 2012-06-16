require 'puppet/face/node_gce'

Puppet::Face.define :node_gce, '0.0.1' do
  action :firewalls do
    summary 'List firewalls.'
    description <<-EOT
      Obtains a list of Google Compute firewalls and displays them on the console.
    EOT

    option '--project=' do
      summary 'The name of the Google Compute project.'

      description <<-EOT
        The name of the Google Compute project to query.
      EOT

      required
    end

    when_invoked do |options|
      Puppet::GoogleCompute.new(options[:project]).firewall_list
    end

    when_rendering :console do |value|
      value.to_s
    end
  end
end
