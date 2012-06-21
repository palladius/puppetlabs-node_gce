class node_gce::params {

  if $::puppetversion =~ /Puppet Enterprise/ {
    $provider = 'pe_gem'
  } else {
    $provider = 'gem'
  }

}
