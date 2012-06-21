class { 'node_gce':
  ensure      => absent,
  # leaving it true will make sure optional components are also removed.
  optional    => true,
  development => true,
}
