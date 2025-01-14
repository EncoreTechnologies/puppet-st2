# @summary Profile to install, configure and manage all client libraries for st2
#
# @param auth
#    Is auth enabled or not.
# @param api_url
#    URL of the StackStorm API service
# @param auth_url
#    URL of the StackStorm Auth service
# @param base_url
#    Base URL for other StackStorm services
# @param username
#    Username for auth on the CLI
# @param password
#    Password for auth on the CLI
# @param api_version
#    Version of the StackStorm API
# @param cacert
#    Path to the SSL CA certficate for the StackStorm services
# @param debug
#    Enable debug mode
# @param cache_token
#    Enable cacheing authentication tokens until they expire
# @param silence_ssl_warnings
#    Enable silencing SSL warnings for self-signed certs
#
# @example Basic Usage
#  include st2::profile::client
#
class st2::profile::client (
  Boolean               $auth                  = $st2::auth,
  Stdlib::HTTPUrl       $api_url               = $st2::cli_api_url,
  Pattern[/v[0-9]+/]    $api_version           = $st2::cli_api_version,
  Stdlib::HTTPUrl       $auth_url              = $st2::cli_auth_url,
  Stdlib::HTTPUrl       $base_url              = $st2::cli_base_url,
  Stdlib::Absolutepath  $cacert                = $st2::cli_cacert,
  Boolean               $cache_token           = $st2::cli_cache_token,
  Boolean               $debug                 = $st2::cli_debug,
  String[1]             $password              = $st2::cli_password,
  Boolean               $silence_ssl_warnings  = $st2::cli_silence_ssl_warnings,
  String[1]             $username              = $st2::cli_username,
) inherits st2 {
  #
  # Setup st2client settings for Root user by default
  st2::client::settings { 'root':
    api_url              => $api_url,
    api_version          => $api_version,
    auth                 => $auth,
    auth_url             => $auth_url,
    base_url             => $base_url,
    cacert               => $cacert,
    cache_token          => $cache_token,
    debug                => $debug,
    homedir              => '/root',
    password             => $password,
    silence_ssl_warnings => $silence_ssl_warnings,
    username             => $username,
  }

  # Setup global environment variables:
  file { '/etc/profile.d/st2.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('st2/etc/profile.d/st2.sh.epp',
      {
        api_url  => $api_url,
        auth_url => $auth_url,
      }
    ),
  }
}
