class st2::profile::mongodb (
  $db_name     = $st2::db_name,
  $db_username = $st2::db_username,
  $db_password = $st2::db_password,
  $db_port     = $st2::db_port,
  $db_bind_ips = $st2::db_bind_ips,
  $version     = $st2::mongodb_version,
  $manage_repo = $st2::mongodb_manage_repo,
  $auth        = $st2::mongodb_auth,
) inherits st2 {
  # if Ubuntu is 20.04 then MongoDB 4.4
  # if the StackStorm version is > 3.3.0 then MongoDB 4.0
  # if the StackStorm version is > 2.4.0 then MongoDB 3.4
  # else use MongoDB 3.2
  if $facts['os']['family'] == 'Debian' and $facts['os']['release']['major'] == '20.04' and st2::version_ge('3.3.0') {
    $_mongodb_version_default = '4.4'
  }
  elsif st2::version_ge('3.3.0') {
    $_mongodb_version_default = '4.0'
  }
  elsif st2::version_ge('2.4.0') {
    $_mongodb_version_default = '3.4'
  }
  else {
    $_mongodb_version_default = '3.2'
  }

  # if user specified a version of MongoDB they want to use, then use that
  # otherwise use the default version of mongo based off the StackStorm version
  $_mongodb_version = $version ? {
    undef   => $_mongodb_version_default,
    default => $version,
  }

  if !defined(Class['mongodb::server']) {
    class { 'mongodb::globals':
      manage_package      => true,
      manage_package_repo => $manage_repo,
      version             => $_mongodb_version,
      bind_ip             => $db_bind_ips,
      manage_pidfile      => false, # mongo will not start if this is true
    }

    class { 'mongodb::client': }

    if $auth == true {
      class { 'mongodb::server':
        port           => $db_port,
        auth           => true,
        create_admin   => true,
        store_creds    => true,
        admin_username => $st2::params::mongodb_admin_username,
        admin_password => $db_password,
      }

      # Ensure MongoDB config is present and service is running
      Class['mongodb::server::install']
      -> Class['mongodb::server::create_admin']
      -> Class['mongodb::server::config']
      -> Class['mongodb::server::service']
    }
    else {
      class { 'mongodb::server':
        port => $db_port,
      }
    }

    # setup proper ordering
    Class['mongodb::globals']
    -> Class['mongodb::client']
    -> Class['mongodb::server']

    # MongoDB module specifies a hard coded version that doesn't match the available
    # version in the repo
    Package <| tag == 'mongodb_package' |> {
      ensure => 'present',
    }

    # Handle more special cases of things that didn't work properly...
    case $facts['os']['family'] {
      'Debian': {
        #############
        # Debian's mongodb doesn't create PID file properly, so we need to
        # create it and set proper permissions
        file { '/var/run/mongod.pid':
          ensure => file,
          owner  => 'mongodb',
          group  => 'mongodb',
          mode   => '0644',
          tag    => 'st2::mongodb::debian',
        }

        File <| title == '/var/lib/mongodb' |> {
          recurse => true,
          tag     => 'st2::mongodb::debian',
        }

        # MongoDB / Apt don't call apt-update before trying to install their packages
        # this fixes that problem
        # This is documented here:
        # https://github.com/puppetlabs/puppetlabs-apt/tree/master#adding-new-sources-or-ppas
        Class['Apt::Update']
        -> Package<| tag == 'mongodb_package' |>
        -> File<| tag == 'st2::mongodb::debian' |>
        -> Service['mongodb']
      }
      default: {
      }
    }

    # configure st2 database
    mongodb::db { $db_name:
      user     => $db_username,
      password => $db_password,
      roles    => $st2::params::mongodb_st2_roles,
      require  => Class['mongodb::server'],
    }
  }
}
