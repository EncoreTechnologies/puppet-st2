# @summary StackStorm compatible installation of nginx and dependencies.
#
# @param manage_repo
#    Set this to false when you have your own repository for nginx
# @param ssl_ciphers
#   Set the nginx SSL ciphers
# @param ssl_protocols
#   Set the nginx SSL protocols
#
# @example Basic Usage
#  include st2::profile::nginx
#
# @example Disable managing the nginx repo so you can manage it yourself
#  class { 'st2::profile::nginx':
#    manage_repo => false,
#  }
#
class st2::profile::nginx (
  Boolean                          $manage_repo    = $st2::nginx_manage_repo,
  Variant[Array[String], String]   $ssl_ciphers    = $st2::nginx_ssl_ciphers,
  Variant[Array[String], String]   $ssl_protocols  = $st2::nginx_ssl_protocols,
) inherits st2 {
  #
  # Convert the ssl_ciphers and ssl_protocols to strings
  $_ssl_ciphers = $ssl_ciphers ? {
    Array[String] => join($ssl_ciphers, ':'),
    String        => $ssl_ciphers,
  }
  $_ssl_protocols = $ssl_protocols ? {
    Array[String] => join($ssl_protocols, ' '),
    String        => $ssl_protocols,
  }

  class { 'nginx':
    confd_purge   => true,
    manage_repo   => $manage_repo,
    ssl_ciphers   => $_ssl_ciphers,
    ssl_protocols => $_ssl_protocols,
  }
}
