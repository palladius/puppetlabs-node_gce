require 'puppet/face/node_gce'

Puppet::Face.define :node_gce, '0.0.1' do

  action :project do

    summary 'Return information on the project in question.'
    description <<-EOT
      Return data about the project instance.
    EOT

    when_invoked do |options|

    end
  end
end
