require 'puppet/face/node_gce'

Puppet::Face.define :node_gce, '0.0.1' do
  action :metadata do
    summary 'List project metadata.'
    description <<-EOT
      Obtains a list of metadata associated with project.
    EOT

    option '--project=' do
      summary 'The name of the Google Compute project.'

      description <<-EOT
        The name of the Google Compute project to query.
      EOT

      required
    end

    when_invoked do |options|
      Puppet::GoogleCompute.new(options[:project]).metadata_list
    end

    when_rendering :console do |value|
      value.to_s
    end
  end
end
