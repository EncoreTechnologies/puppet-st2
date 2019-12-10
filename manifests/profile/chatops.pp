# @summary Profile to install and configure chatops for st2
#
# @note This class doesn't need to be invoked directly, instead it's best to customize
#       it through the main +::st2+ class
#
# @param version
#    Version of the st2chatops package to install
# @param hubot_log_level
#    Hubot log level
# @param hubot_express_port
#    Express port hubot listens to
# @param tls_cert_reject_unauthorized
#    Set to 1 when using self signed certs
# @param hubot_name
#    Name of the bot in chat. Should be properly quoted if it has special characters,
#    example: '"MyBot!"'
# @param hubot_alias
#    Character to trigger the bot at the beginning of a message. Must be properly
#    quoted of it's a special character, example: "'!'"
# @param npm_packages
#    NodeJS packages to be installed (usually a hubot adapter)
# @param adapter_config
#    Configuration parameters for Hubot adapter (hash)
# @param api_key
#    API key generated by <code>st2 apikey create</code> that hubot will use to post data back
#    to StackStorm.
# @param st2_hostname
#    Hostname of the StackStorm instance that chatops will connect to for API and Auth.
#    If unspecified it will use the default in <code>/opt/stackstorm/chatops/st2chatops.env</code>
# @param web_url
#    Public URL of StackStorm instance. Used by chatops to offer links to execution details in a chat.
#    If unspecified it will use the default in <code>/opt/stackstorm/chatops/st2chatops.env</code>
# @param api_url
#    URL of the StackStorm API service
# @param auth_url
#    URL of the StackStorm Auth service
# @param auth_username
#    StackStorm auth Username for ChatOps to communicate back with StackStorm.
#    Used if +api_key+ is not specified (optional)
# @param auth_password
#    StackStorm auth Password for ChatOps to communicate back with StackStorm.
#    Used if +api_key+ is not specified (optional)
#
# @example Basic Usage
#   class { '::st2':
#     chatops_hubot_name => '"@RosieRobot"',
#     chatops_api_key    => '"xxxxyyyyy123abc"',
#     chatops_adapter    => {
#       hubot-adapter => {
#         package => 'hubot-rocketchat',
#         source  => 'git+ssh://git@git.company.com:npm/hubot-rocketchat#master',
#       },
#     },
#     chatops_adapter_conf => {
#       HUBOT_ADAPTER        => 'rocketchat',
#       ROCKETCHAT_URL       => 'https://chat.company.com',
#       ROCKETCHAT_ROOM      => 'stackstorm',
#       LISTEN_ON_ALL_PUBLIC => 'true',
#       ROCKETCHAT_USER      => 'st2',
#       ROCKETCHAT_PASSWORD  => 'secret123',
#       ROCKETCHAT_AUTH      => 'password',
#       RESPOND_TO_DM        => 'true',
#     },
#   }
#
class st2::profile::chatops (
  $version                      = $::st2::version,
  $hubot_log_level              = $::st2::chatops_hubot_log_level,
  $hubot_express_port           = $::st2::chatops_hubot_express_port,
  $tls_cert_reject_unauthorized = $::st2::chatops_tls_cert_reject_unauthorized,
  $hubot_name                   = $::st2::chatops_hubot_name,
  $hubot_alias                  = $::st2::chatops_hubot_alias,
  $npm_packages                 = $::st2::chatops_adapter,
  $adapter_config               = $::st2::chatops_adapter_conf,
  $api_key                      = $::st2::chatops_api_key,
  $st2_hostname                 = $::st2::chatops_st2_hostname,
  $web_url                      = $::st2::chatops_web_url,
  $api_url                      = $::st2::chatops_api_url,
  $auth_url                     = $::st2::chatops_auth_url,
  $auth_username                = $::st2::cli_username,
  $auth_password                = $::st2::cli_password,
) inherits st2 {
  include '::st2::params'

  $_chatops_packages = $::st2::params::st2_chatops_packages
  $_chatops_dir = $::st2::params::st2_chatops_dir
  $_chatops_env_file = "${_chatops_dir}/st2chatops.env"

  ########################################
  ## Packages
  package { $_chatops_packages:
    ensure => $version,
    tag    => ['st2::packages', 'st2::chatops::packages'],
  }

  ########################################
  ## Config
  file { $_chatops_env_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('st2/opt/stackstorm/chatops/st2chatops.env.erb'),
    tag     => 'st2::chatops::config',
  }

  file { $::st2::params::st2_chatops_global_env_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('st2/etc/sysconfig/st2chatops.erb'),
    tag     => 'st2::chatops::config',
  }


  ########################################
  ## Additional nodejs packages
  include st2::profile::nodejs

  $npm_package_defaults = {
    ensure  => present,
    target  => $_chatops_dir,
    require => Class['St2::Profile::Nodejs'],
    tag     => 'st2::chatops::npm_package',
  }

  create_resources('::nodejs::npm', $npm_packages, $npm_package_defaults)

  ########################################
  ## Services
  service { $::st2::params::st2_chatops_services:
    ensure => 'running',
    enable => true,
    tag    => 'st2::chatops::service',
  }

  ########################################
  ## Dependencies
  Package<| tag == 'st2::chatops::packages' |>
  -> File<| tag == 'st2::chatops::config' |>
  ~> Service<| tag == 'st2::chatops::service' |> # notify to force a refresh

  # st2api, st2auth, etc need to be running in order for st2chatops to work
  Service<| tag == 'st2::service' |>
  -> Service<| tag == 'st2::chatops::service' |>

  Nodejs::Npm<| tag == 'st2::chatops::npm_package' |>
  -> Service<| tag == 'st2::chatops::service' |>
}
