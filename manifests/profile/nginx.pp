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
  Boolean  $manage_repo    = $st2::nginx_manage_repo,
  String   $ssl_ciphers    = $st2::nginx_ssl_ciphers,
  String   $ssl_protocols  = $st2::nginx_ssl_protocols,
) inherits st2 {
  #
  class { 'nginx':
    confd_purge   => true,
    manage_repo   => $manage_repo,
    ssl_ciphers   => $ssl_ciphers,
    ssl_protocols => $ssl_protocols,
  }
}
