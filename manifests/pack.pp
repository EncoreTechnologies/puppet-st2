# @summary Manages a StackStorm Pack
#
# @param ensure
#    Whether the pack should be present or absent.
# @param pack
#    Name of the pack to install.
# @param repo_url
#    URL of the package to install when not installing from the exchange.
# @param config
#    Hash that will be translated into YAML in the pack's config file after installation.
# @param version
#    Version of the pack to install.
#
# @example Basic Usage
#  st2::pack { 'puppet': }
#
# @example Install from a custom URL
#  st2::pack { 'custom':
#    repo_url => 'http://github.com/myorg/stackstorm-custom.git',
#  }
#
define st2::pack (
  Enum['present', 'absent']   $ensure   = present,
  String                      $pack     = $name,
  Stdlib::HTTPUrl             $repo_url = undef,
  Hash                        $config   = undef,
  String                      $version  = undef,
) {
  include st2
  $_cli_username = $st2::cli_username
  $_cli_password = $st2::cli_password
  $_cli_apikey = $st2::cli_apikey

  st2_pack { $pack:
    ensure   => $ensure,
    name     => $pack,
    user     => $_cli_username,
    password => $_cli_password,
    apikey   => $_cli_apikey,
    source   => $repo_url,
    version  => $version,
  }

  if $config {
    validate_hash($config)
    file { "/opt/stackstorm/configs/${pack}.yaml":
      ensure  => file,
      mode    => '0640',
      owner   => 'st2',
      group   => 'root',
      content => epp('st2/config.yaml.epp'),
    }

    # Register package after it is downloaded and configured
    St2_pack<| name == $pack |>
    -> File["/opt/stackstorm/configs/${pack}.yaml"]
    ~> Exec<| tag == 'st2::register-configs' |>
  }

  Service<| tag == 'st2::service' |> -> St2_pack<||>
  Exec<| tag == 'st2::reload' |> -> St2_pack<||>
}
