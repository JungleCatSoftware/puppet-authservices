class authservices::db {

  include cassandra::datastax_repo
  include cassandra::java

  class { 'cassandra':
    cluster_name          => 'AuthServices',
    package_ensure        => '2.2.4',
    listen_address        => $::ipaddress_eth1,
    listen_interface      => 'eth1',
    broadcast_address     => $::ipaddress_eth1,
    broadcast_rpc_address => $::ipaddress_eth1,
    rpc_address           => $::ipaddress_eth1,
    seeds                 => $::ipaddress_eth1,
  }

  include limits

  Class['cassandra::datastax_repo'] -> Class['cassandra']
  Class['cassandra::java'] -> Class['cassandra']
  Class['limits'] ~> Service['cassandra']
}
