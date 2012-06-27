require 'puppet/face/node_gce'

Puppet::Face.define :node_gce, '0.0.1' do
  action :add_metadata do
    summary 'Add or update project metadata sshkey.'
    description <<-EOT
      Add project metadata sshkey.
      
      SSH keys may take 60 seconds to propogate.
    EOT

    option '--project=' do
      summary 'The name of the Google Compute project.'

      description <<-EOT
        The name of the Google Compute project to query.
      EOT

      required
    end

    option '--sshkey=' do
      summary 'The metadata sshkey file.'

      description <<-EOT
        The metadata sshkey file.
      EOT

      required
    end

    option '--user=' do
      summary 'The metadata sshkey user.'

      description <<-EOT
        The metadata sshkey user (defaults to current user).
      EOT
    end

    when_invoked do |options|
      username = options[:user] || Etc.getpwuid(Process.uid).name
      sshkey = File.open(File.expand_path(options[:sshkey]), 'r') { |f| f.read }
      Puppet::GoogleCompute.new(options[:project]).sshkeys_add(username, sshkey)
    end

    when_rendering :console do |value|
      value.to_s
    end
  end
end
