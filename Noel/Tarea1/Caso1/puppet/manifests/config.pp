  # Guatemala 19 de julio del 2016
  # Datum, Taller Cassandra
  # Tarea 1, Caso 1
  # Receta Prerrequisitos para la instalación de Oracle 12c R1
  # Keneth Efrén Ubeda Arriaza
  # fuente: https://oracle-base.com/articles/12c/oracle-db-12cr1-installation-on-oracle-linux-6
  # Sistema operativo Oracle linux 6


  # actualizacion de repositorios
  exec { 'actualizacion':
    command => 'yum list',
    path    => ['/usr/bin', '/usr/sbin',],
  }

  # instalacion de paquete de presinstalacion
  package { 'oracle-rdbms-server-12cR1-preinstall':
    ensure => installed,
    require => Exec['actualizacion'],
  }

  # cambiar password usuario oracle
  exec { 'oracle_password':
    command => 'echo datum2016 | passwd oracle --stdin',
    path    => ['/usr/bin', '/bin',],
    require => Package['oracle-rdbms-server-12cR1-preinstall']
  }

  # modificar archivo "/etc/security/limits.d/90-nproc.conf"
  file_line { 'nproc':
    path              => '/etc/security/limits.d/90-nproc.conf',
    line              => '* - nproc 16384',
    match             => '\*',
    match_for_absence => true,
    require => Exec['oracle_password'],
  }

  # Editar el archivo "/etc/selinux/config"
  file_line { 'selinux':
    path              => '/etc/selinux/config',
    line              => 'SELINUX=permissive',
    match             => 'SELINUX=disabled',
    match_for_absence => true,
    require => File_line['nproc'],
    #notify => Reboot['after_run'],
  }

  # Reiniciar o ejectuar el siguiente comando
  #reboot { 'after_run':
  #  apply  => finished,
  #}

  # Deshabilitar o configurar el firewall
  service{ 'iptables':
    stop => '/sbin/iptables stop',
    require => File_line['selinux'],
  }
  exec { 'chkconifg':
    command => 'chkconfig iptables off',
    path    => ['/usr/bin', '/sbin',],
    require => Service['iptables'],
  }

  # Crear directorios para la instalación de Oracle
  exec { 'directorios':
    command => 'mkdir -p /u01/app/oracle/product/12.1.0.2/db_1',
    path => ['/bin',],
    require => Exec['chkconifg'],

  }
  exec { 'chown_oracle':
    command => 'chown -R oracle:oinstall /u01',
    path => ['/bin',],
    require => Exec['directorios'],
  }
  exec { 'chmod_oracle':
    command => 'chmod -R 775 /u01',
    path => ['/bin',],
    require => Exec['directorios'],

  }

  # Variables de entorno
  $defaults = {
    path => '/home/oracle/.bash_profile',
    require => Exec['directorios'],
  }
  $data = {
      'TMP' => {
          line => 'export TMP=/tmp',
      },
      'TMPDIR' => {
          line => 'export TMPDIR=$TMP',
          require => File_line['TMP'],
      },
      'ORACLE_HOSTNAME' => {
          line => 'export ORACLE_HOSTNAME=oracle',
          require => File_line['TMPDIR'],
      },
      'ORACLE_UNQNAME' => {
          line => 'export ORACLE_UNQNAME=orcl',
          require => File_line['ORACLE_HOSTNAME'],
      },
      'ORACLE_BASE' => {
          line => 'export ORACLE_BASE=/u01/app/oracle',
          require => File_line['ORACLE_UNQNAME'],
      },
      'ORACLE_HOME' => {
          line => 'export ORACLE_HOME=$ORACLE_BASE/product/12.1.0.2/db_1',
          require => File_line['ORACLE_BASE'],
      },
      'ORACLE_SID' => {
          line => 'export ORACLE_SID=orcl',
          require => File_line['ORACLE_HOME'],
      },
      'PATH' => {
          line => 'export PATH=/usr/sbin:$PATH',
          require => File_line['ORACLE_SID'],
      },
      'PATH1' => {
          line => 'export PATH=$ORACLE_HOME/bin:$PATH',
          require => File_line['PATH'],
      },
      'LD_LIBRARY_PATH' => {
          line => 'export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib',
          require => File_line['PATH1'],
      },
      'CLASSPATH' => {
          line => 'export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib',
          require => File_line['LD_LIBRARY_PATH'],
      }
  }
  create_resources('file_line', $data, $defaults)
