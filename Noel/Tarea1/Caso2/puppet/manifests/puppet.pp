$user       = "datum"
$group      = "datum"
$dir   = "/home/${user}/node0"
$cassandra  = "http://apache.claz.org/cassandra/2.1.14/apache-cassandra-2.1.14-bin.tar.gz"

user {$user:
  ensure      => present,
  gid         => $group,
  managehome  => true,
  require     => Group[$group]
}
group {$group:
  ensure      => present,
}

file {$dir:
  ensure      => directory,
  owner       => $user,
  group       => $group,
  mode        => "755",
  require     => User[$user],
}
package {'java-1.8.0-openjdk':
  ensure      => installed
}
package {'wget':
  ensure      => installed,
}
exec{ 'descargar_cassandra':
  command     => "wget -O ${$dir}/cassandra-2.1.14.tar.gz ${cassandra}",
  path        => ['/usr/bin','/bin'],
  timeout     => 1500,
  require     => [Package["wget"],File[$dir]],
}
exec { "descomprimir_cassandra":
	command     => "/bin/tar -zxvf ${$dir}/cassandra-2.1.14.tar.gz",
	cwd         => "${$dir}",
	require     => Exec["download_cassandra"],
}

file_line { 'hosts':
  path => '/etc/hosts',
  line => 'caso00 5.5.5.0',
}

file_line { 'hosts1':
  path => '/etc/hosts',
  line => 'caso01 5.5.5.1',
}

file_line { 'host2':
  path => '/etc/hosts',
  line => 'caso02 5.5.5.2',
}