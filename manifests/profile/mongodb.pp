# == Class st2::profile::mongodb
#
# st2 compatable installation of MongoDB and dependencies for use with
# StackStorm
#
# === Parameters
#
#  This module contains no parameters
#
# === Variables
#
#  This module contains no variables
#
# === Examples
#
#  include st2::profile::mongodb
#
class st2::profile::mongodb (
  $db_name     = $st2::db_name,
  $db_username = $st2::db_username,
  $db_password = $st2::db_password,
  $db_port     = $st2::db_port,
  $db_bind_ips = $st2::db_bind_ips,
  $version     = $st2::mongdb_version,
) inherits st2 {

  # if user specified a version of MongoDB they want to use, then use that
  # otherwise auto-determine the version to use (as of st2 v2.3 MongoDB = 3.2)
  # TODO in the future use semantic version compare against $st2::version
  $mongodb_version = $version ? {
    undef   => '3.2',
    default => $version,
  }

  $mongo_db_password = $db_password ? {
    undef   => $st2::cli_password,
    default => $db_password,
  }

  if !defined(Class['::mongodb::server']) {

    class { 'mongodb::globals':
      manage_package      => true,
      manage_package_repo => true,
      version             => $mongodb_version,
      bind_ip             => $db_bind_ips,
      manage_pidfile      => false, # mongo will not start if this is true
    }->
    class { 'mongodb::client':
    }->
    class { 'mongodb::server':
      auth           => true,
      port           => $db_port,
      create_admin   => true,
      store_creds    => true,
      admin_username => $st2::params::mongodb_admin_username,
      admin_password => $mongo_db_password,
    }

    # TODO: is this just redhat specific?
    Package <| title == 'mongodb_client' |> {
      ensure => 'present'
    }

    Package <| title == 'mongodb_server' |> {
      ensure => 'present'
    }

    # configure st2 database
    mongodb::db { $db_name:
      user     => $db_username,
      password => $mongo_db_password,
      roles    => $st2::params::mongodb_st2_roles,
      require  => Class['::mongodb::server'],
    }
  }

}
