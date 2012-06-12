require 'puppet/face/node_gce'

Puppet::Face.define :node_gce, '0.0.1' do

  action :project do

    summary 'Return information on the project in question.'
    description <<-EOT
      Return data about the project instance.
    EOT

    option '--project=' do
      summary 'The name of the Google Compute project.'

      description <<-EOT
        The name of the Google Compute project to query.
      EOT

      required
    end

    when_invoked do |options|
      Puppet::GoogleCompute.get_project(options[:project])
    end

    when_rendering :console do |value|
      value.to_s
    end
  end
end
