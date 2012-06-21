class { 'node_gce':
  ensure      => present,
  optional    => true,
  development => false,
}
