class authservices::db {

  include cassandra::datastax_repo
  include cassandra::java
  include limits

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

  # Patch CASSANDRA-11716: https://issues.apache.org/jira/browse/CASSANDRA-11716
  $cassandra_env_patch  = '/tmp/cassandra-env.sh'
  $cassandra_env_script = '/etc/cassandra/cassandra-env.sh'
  file { $cassandra_env_patch:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => join([
      "--- ${cassandra_env_script}	2016-02-08 21:26:57.000000000 +0000",
      "+++ ${cassandra_env_patch}	2016-05-05 07:53:12.573016521 +0100",
      '@@ -99,7 +99,7 @@',
      '     exit 1;',
      ' fi',
      ' ',
      '-if [ "$JVM_VERSION" \< "1.8" ] && [ "$JVM_PATCH_VERSION" \< "25" ] ; then',
      '+if [ "$JVM_VERSION" \< "1.8" ] && [ "$JVM_PATCH_VERSION" -lt "25" ] ; then',
      '     echo "Cassandra 2.0 and later require Java 7u25 or later."',
      '     exit 1;',
      ' fi',
      '',
    ], "\n"),
  }
  exec { 'Patch Cassandra_env.sh':
    path    => '/usr/bin:/bin',
    command => "patch -N --silent ${cassandra_env_script} ${cassandra_env_patch}",
    onlyif  => "patch -N --dry-run --silent ${cassandra_env_script} ${cassandra_env_patch}",
  }

  File[$cassandra_env_patch] ~> Exec['Patch Cassandra_env.sh']
  Package['cassandra'] ~> Exec['Patch Cassandra_env.sh']
  Exec['Patch Cassandra_env.sh'] -> Service['cassandra']
  Class['cassandra::datastax_repo'] -> Class['cassandra']
  Class['cassandra::java'] -> Class['cassandra']
  Class['limits'] ~> Service['cassandra']
}
