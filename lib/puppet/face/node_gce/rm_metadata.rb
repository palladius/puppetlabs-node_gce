require 'puppet/face/node_gce'

Puppet::Face.define :node_gce, '0.0.1' do
  action :rm_metadata do
    summary 'Remove project metadata sshkey.'
    description <<-EOT
      Remove project metadata sshkey.
      
      SSH keys may take 60 seconds to propogate.
    EOT

    option '--project=' do
      summary 'The name of the Google Compute project.'

      description <<-EOT
        The name of the Google Compute project to query.
      EOT

      required
    end

    option '--user=' do
      summary 'The metadata sshkey user.'

      description <<-EOT
        The metadata sshkey user account to remove.
      EOT

      required
    end

    when_invoked do |options|
      Puppet::GoogleCompute.new(options[:project]).sshkeys_rm(username)
    end

    when_rendering :console do |value|
      value.to_s
    end
  end
end
