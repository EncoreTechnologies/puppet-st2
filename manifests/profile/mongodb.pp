class st2::profile::mongodb {
  include '::st2::params'

  if !defined(Class['::mongodb::server']) {
    class { '::mongodb::server': }
  }

  $_mongodb_dependencies = $::osfamily ? {
    'Debian' => $::st2::params::debian_mongodb_dependencies,
    default  => undef,
  }

  if $_mongodb_dependencies {
    ::st2::dependencies::install { $_mongodb_dependencies: }
  }
}
