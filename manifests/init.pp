# @summary Base class for st2 module. Used as top-level to set parameters via Hiera, this class does not need to be called directly.
#
# @param version
#   Version of StackStorm package to install (default = 'present')
#   See the package 'ensure' property:
#   https://puppet.com/docs/puppet/5.5/types/package.html#package-attribute-ensure
#
# @param [String] python_version
#   Version of Python to install. Default is 'system' meaning the system version
#   of Python will be used.
#   To install Python 3.8 on RHEL/CentOS 7 specify '3.8'.
#   To install Python 3.8 on Ubuntu 16.05 specify 'python3.8'.
#
# @param [St2::Repository] repository
#   Release repository to enable. 'stable', 'unstable'
#   (default = 'stable')
# @param conf_dir
#   The directory where st2 configs are stored
# @param conf_file
#   The path where st2 config is stored
# @param use_ssl
#   Enable/Disable SSL for all st2 APIs
# @param ssl_cert_manage
#   Boolean to determine if this module should manage the SSL certificate used by nginx.
# @param ssl_dir
#   Directory where st2web will look for its SSL info.
#   (default: /etc/ssl/st2)
# @param ssl_cert
#   Path to the file where the StackStorm SSL cert will
#   be generated. (default: /etc/ssl/st2/st2.crt)
# @param ssl_key
#   Path to the file where the StackStorm SSL key will
#   be generated. (default: /etc/ssl/st2/st2.key)
# @param auth
#   Toggle to enable/disable auth (Default: true)
# @param auth_api_url
#   URL where StackStorm auth service will communicate
#   with the StackStorm API service
# @param auth_debug
#   Toggle to enable/disable auth debugging (Default: false)
# @param auth_mode
#   Auth mode, either 'standalone' or 'backend (default: 'standalone')
# @param auth_backend
#   Determines which auth backend to configure. (default: flat_file)
#   Available backends:
#   - flat_file
#   - keystone
#   - ldap
#   - mongodb
#   - pam
# @param auth_backend_config
#   Hash of parameters to pass to the auth backend
#   class when it's instantiated. This will be different
#   for every backend. Please see the corresponding
#   backend class to determine what the config options
#   should be.
# @param cli_base_url
#   CLI config - Base URL lives
# @param cli_api_version
#   CLI config - API Version
# @param cli_debug
#   CLI config - Enable/Disable Debug
# @param cli_cache_token
#   CLI config - True to cache auth token until expries
# @param cli_username
#   CLI config - Auth Username
# @param cli_password
#   CLI config - Auth Password
# @param cli_apikey
#   CLI config - StackStorm API Key to use for pack and k/v installation, instead of user/pass
# @param cli_api_url
#   CLI config - API URL
# @param cli_auth_url
#   CLI config - Auth URL
# @param actionrunner_workers
#   Set the number of actionrunner processes to start
# @param packs
#   Hash of st2 packages to be installed
# @param packs_group
#   Name of the group that will own the /opt/stackstorm/packs directory (default: st2packs)
# @param index_url
#   Url to the StackStorm Exchange index file. (default undef)
# @param syslog
#   Routes all log messages to syslog
# @param syslog_host
#   Syslog host. Default: localhost
# @param syslog_protocol
#   Syslog protocol. Default: udp
# @param syslog_port
#   Syslog port. Default: 514
# @param syslog_facility
#   Syslog facility. Default: local7
# @param ssh_key_location
#   Location on filesystem of Admin SSH key for remote runner
# @param db_host
#   Hostname to talk to st2 db
# @param db_port
#   Port for db server for st2 to talk to
# @param db_bind_ips
#   Array of bind IP addresses for MongoDB to listen on
# @param db_name
#   Name of db to connect to (default: 'st2')
# @param db_username
#   Username to connect to db with (default: 'stackstorm')
# @param db_password
#   Password for 'admin' and 'stackstorm' users in MongDB.
#   If 'undef' then use $cli_password
# @param mongodb_version
#   Version of MongoDB to install. If not provided it
#   will be auto-calcuated based on $version
#   (default: undef)
# @param mongodb_manage_repo
#   Set this to false when you have your own repositories
#   for MongoDB (default: true)
# @param mongodb_auth
#   Boolean determining if auth should be enabled for
#   MongoDB. Note: On new versions of Puppet (4.0+)
#   you'll need to disable this setting.
#   (default: true)
# @param nginx_manage_repo
#   Set this to false when you have your own repositories for nginx
#   (default: true)
# @param nginx_ssl_ciphers
#   String or list of strings of acceptable SSL ciphers to configure nginx with.
#   @see http://nginx.org/en/docs/http/ngx_http_ssl_module.html
#   Note: the defaults are setup to restrict to TLSv1.2 and TLSv1.3 secure ciphers only
#         (secure by default). The secure ciphers for each protocol were obtained via:
#         @see https://wiki.mozilla.org/Security/Server_Side_TLS
# @param nginx_ssl_protocols
#   String or list of strings of acceptable SSL protocols to configure nginx with.
#   @see http://nginx.org/en/docs/http/ngx_http_ssl_module.html
#   Note: the defaults are setup to restrict to TLSv1.2 and TLSv1.3 only (secure by default)
# @param nginx_ssl_port
#   What port should nginx listen on publicly for new connections (default: 443)
# @param nginx_client_max_body_size
#   The maximum size of the body for a request allow through nginx.
#   We default this to '0' to allow for large messages/payloads/inputs/results
#   to be passed through nginx as is normal in the StackStorm context.
#   @see http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size
# @param web_root
#    Directory where the StackStorm WebUI site lives on the filesystem
# @param timersengine_enabled
#   Set to true if the st2timersengine service should be enabled
#   on this node (default: true)
# @param timersengine_timezone
#   The local timezone for this node. (default: 'America/Los_Angeles')
# @param scheduler_sleep_interval
#   How long (in seconds) to sleep between each action
#   scheduler main loop run interval. (default = 0.1)
# @param scheduler_gc_interval
#   How often (in seconds) to look for zombie execution requests
#   before rescheduling them. (default = 10)
# @param scheduler_pool_size
#   The size of the pool used by the scheduler for scheduling
#   executions. (default = 10)
# @param chatops_adapter
#   Adapter package(s) to be installed with npm. List of hashes.
# @param chatops_adapter_conf
#   Configuration parameters for Hubot adapter (hash)
# @param chatops_hubot_log_level
#   Logging level for hubot (string)
# @param chatops_hubot_express_port
#   Port that hubot operates on (integer or string)
# @param chatops_tls_cert_reject_unauthorized
#   Should hubot validate SSL certs
#   Set to 1 when using self signed certs
# @param chatops_hubot_name
#   Name of the bot in chat. Should be
#   properly quoted if it has special characters,
#   example: '"MyBot!"'
# @param chatops_hubot_alias
#   Character to trigger the bot at the
#   beginning of a message. Must be properly
#   quoted of it's a special character,
#   example: "'!'"
# @param chatops_api_key
#   API key generated by `st2 apikey create`
#   that hubot will use to post data back
#   to StackStorm.
#   (default: undef)
# @param chatops_st2_hostname
#   Hostname of the StackStorm instance
#   that chatops will connect to for
#   API and Auth. If unspecified it will
#   use the default in /opt/stackstorm/chatops/st2chatops.env
#   (default: undef)
# @param chatops_api_url
#   ChatOps config - API URL
# @param chatops_auth_url
#   ChatOps config - Auth URL
# @param chatops_web_url
#   Public URL of StackStorm instance.
#   used by chatops to offer links to
#   execution details in a chat.
#   If unspecified it will use the
#   default in /opt/stackstorm/chatops/st2chatops.env
#   (default: undef)
# @param nodejs_version
#   Version of NodeJS to install. If not provided it
#   will be auto-calcuated based on $version
#   (default: undef)
# @param nodejs_manage_repo
#   Set this to false when you have your own repositories
#   for NodeJS (default: true)
# @param redis_bind_ip
#   Bind IP of the Redis server. Default is 127.0.0.1
# @param workflowengine_num
#   The number of workflowengines to have in an active active state (default: 1)
# @param scheduler_num
#   The number of schedulers to have in an active active state (default: 1)
# @param rulesengine_num
#   The number of rulesengines to have in an active active state (default: 1)
# @param notifier_num
#   The number of notifiers to have in an active active state (default: 1)
# @param erlang_url
#   The url for the erlang repositiory to be used for rabbitmq
# @param erlang_key
#   The gpg key for the erlang repositiory to be used for rabbitmq
# @param validate_output_schema
#   Enable/disable output schema validation in StackStorm
# @param hostname
#   Hostname of the StackStorm server.  This is used as the default to drive a lot of
#   other parameters in the st2 class such as auth URL, MongoDB host, RabbitMQ host, etc.
#   (default: 127.0.0.1)
# @param admin_password
#   Password of the StackStorm admin user.
# @param admin_username
#   Username of the StackStorm admin user.
# @param api_port
# @param auth_port
# @param cli_silence_ssl_warnings
# @param datastore_aes_key
# @param datastore_aes_mode
# @param datastore_aes_size
# @param datastore_hmac_key
# @param datastore_hmac_size
# @param datastore_keys_dir
# @param datastore_key_path
# @param erlang_key_id
# @param erlang_key_source
# @param erlang_packages
# @param erlang_rhel_gpgcheck
# @param erlang_rhel_repo_gpgcheck
# @param erlang_rhel_sslcacert_location
# @param erlang_rhel_sslverify
# @param manage_datastore_key
# @param manage_epel_repo
# @param metric_driver
# @param metric_host
# @param metric_port
# @param metrics_include
# @param ng_init
# @param nginx_basicstatus_enabled
# @param nginx_basicstatus_port
# @param python_use_epel_repo
# @param rabbitmq_bind_ip
# @param rabbitmq_hostname
# @param rabbitmq_password
# @param rabbitmq_port
# @param rabbitmq_username
# @param rabbitmq_vhost
# @param redis_hostname
# @param redis_manage_repo
# @param redis_password
# @param redis_port
# @param stream_port

#
#
# @example Basic Usage
#   include st2
#
# @example Variables can be set in Hiera and take advantage of automatic data bindings:
#   st2::version: 2.10.1
#
# @example Customizing parameters
#   # best practice is to change default username/password
#   class { 'st2::params':
#     admin_username => 'st2admin',
#     admin_password => 'SuperSecret!',
#   }
#
#   class { 'st2':
#     version => '2.10.1',
#   }
#
# @example Different passwords for each database (MongoDB, RabbitMQ)
#   class { 'st2':
#     # StackStorm user
#     cli_username        => 'st2admin',
#     cli_password        => 'SuperSecret!',
#     # MongoDB user for StackStorm
#     db_username         => 'admin',
#     db_password         => 'KLKfp9#!2',
#     # RabbitMQ user for StackStorm
#     rabbitmq_username   => 'st2',
#     rabbitmq_password   => '@!fsdf0#45',
#   }
#
# @example Install with python 3.8 (if not default on your system)
#   $st2_python_version = $facts['os']['family'] ? {
#     'RedHat' => '3.8',
#     'Debian' => 'python3.8',
#   }
#   class { 'st2':
#     python_version            => $st2_python_version,
#   }
class st2 (
  Stdlib::Hostname            $hostname                   = '127.0.0.1',
  Integer                     $actionrunner_workers       = 10,
  String[1]                   $admin_password             = undef,
  String[1]                   $admin_username             = 'admin',
  Stdlib::Port                $api_port                   = 9101,
  Stdlib::HTTPUrl             $auth_api_url               = "http://${hostname}:${api_port}",
  Hash                        $auth_backend_config        = $st2::params::auth_backend_config,
  String                      $auth_backend               = 'flat_file',
  Boolean                     $auth_debug                 = false,
  String                      $auth_mode                  = 'standalone',
  Stdlib::Port                $auth_port                  = 9100,
  Boolean                     $auth                       = true,
  Hash                        $chatops_adapter            = {},
  Hash                        $chatops_adapter_conf       = $st2::params::chatops_adapter_conf,
  Optional[String]            $chatops_api_key            = undef,
  Stdlib::HTTPUrl             $chatops_api_url            = "https://${hostname}/api",
  Stdlib::HTTPUrl             $chatops_auth_url           = "https://${hostname}/auth",
  String                      $chatops_hubot_alias        = "'!'",
  Stdlib::Port                $chatops_hubot_express_port = 8081,
  String                      $chatops_hubot_log_level    = 'debug',
  String                      $chatops_hubot_name         = '"hubot"',
  Stdlib::Host                $chatops_st2_hostname       = $hostname,
  Enum['0', '1']              $chatops_tls_cert_reject_unauthorized = '0',
  Optional[Stdlib::HTTPUrl]   $chatops_web_url            = undef,
  String                      $cli_apikey                 = undef,
  Stdlib::HTTPUrl             $cli_api_url                = "http://${hostname}:${api_port}",
  Patern[/v[0-9]+/]           $cli_api_version            = 'v1',
  Stdlib::HTTPUrl             $cli_auth_url               = "http://${hostname}:${auth_port}",
  Stdlib::HTTPUrl             $cli_base_url               = "http://${hostname}",
  Boolean                     $cli_cache_token            = true,
  Boolean                     $cli_debug                  = false,
  String[1]                   $cli_password               = $admin_password,
  Boolean                     $cli_silence_ssl_warnings   = false,
  String[1]                   $cli_username               = 'st2admin',
  Stdlib::Absolutepath        $conf_dir                   = '/etc/st2',
  Stdlib::Absolutepath        $conf_file                  = "${conf_dir}/st2.conf",
  Optional[String]            $datastore_aes_key          = undef,
  String                      $datastore_aes_mode         = 'CBC',
  Integer                     $datastore_aes_size         = 256,
  Optional[String]            $datastore_hmac_key         = undef,
  Integer                     $datastore_hmac_size        = 256,
  Stdlib::Absolutepath        $datastore_keys_dir         = "${conf_dir}/keys",
  Stdlib::Absolutepath        $datastore_key_path         = "${datastore_keys_dir}/datastore_key.json",
  Array[Stdlib::IP::Address]  $db_bind_ips                = ['127.0.0.1'],
  Stdlib::Host                $db_host                    = $hostname,
  String[1]                   $db_name                    = 'st2',
  String[1]                   $db_password                = $admin_password,
  Stdlib::Port                $db_port                    = '27017',
  String[1]                   $db_username                = 'stackstorm',
  String                      $erlang_key                 = $st2::params::erlang_key,
  String                      $erlang_key_id              = $st2::params::erlang_key_id,
  String                      $erlang_key_source          = $st2::params::erlang_key_source,
  Array[String[1]]            $erlang_packages            = ['erlang'],
  Enum[0, 1]                  $erlang_rhel_gpgcheck       = 0,
  Enum[0, 1]                  $erlang_rhel_repo_gpgcheck  = 1,
  Stdlib::Absolutepath        $erlang_rhel_sslcacert_location = $st2::params::erlang_rhel_sslcacert_location,
  Enum[0, 1]                  $erlang_rhel_sslverify      = 1,
  Stdlib::HTTPUrl             $erlang_url                 = $st2::params::erlang_url,
  Optional[Stdlib::HTTPUrl]   $index_url                  = undef,
  Boolean                     $manage_datastore_key       = false,
  Boolean                     $manage_epel_repo           = true,
  String                      $metric_driver              = 'statsd',
  Stdlib::Host                $metric_host                = $hostname,
  Stdlib::Port                $metric_port                = 8125,
  Boolean                     $metrics_include            = false,
  Boolean                     $mongodb_auth               = true,
  Boolean                     $mongodb_manage_repo        = true,
  Optional[String]            $mongodb_version            = undef,
  Boolean                     $ng_init                    = true,
  Boolean                     $nginx_basicstatus_enabled  = false,
  Stdlib::Port                $nginx_basicstatus_port     = 9103,
  String[1]                   $nginx_client_max_body_size = '0',
  Boolean                     $nginx_manage_repo          = true,
  Array[String]               $nginx_ssl_ciphers          = $st2::params::nginx_ssl_ciphers,
  Stdlib::Port                $nginx_ssl_port             = 443,
  Array[String]               $nginx_ssl_protocols        = ['TLSv1.2', 'TLSv1.3'],
  Boolean                     $nodejs_manage_repo         = true,
  Optional[String]            $nodejs_version             = undef,
  Integer[1]                  $notifier_num               = 1,
  Variant[String, Hash]       $packs                      = {},
  String[1]                   $packs_group                = 'st2packs',
  Boolean                     $python_use_epel_repo       = true,
  St2::Ensure                 $python_version             = 'system',
  Stdlib::IP::Address         $rabbitmq_bind_ip           = '127.0.0.1',
  Stdlib::Host                $rabbitmq_hostname          = $hostname,
  String[1]                   $rabbitmq_password          = $admin_password,
  Stdlib::Port                $rabbitmq_port              = 5672,
  String[1]                   $rabbitmq_username          = $admin_username,
  String                      $rabbitmq_vhost             = '/',
  Stdlib::IP::Address         $redis_bind_ip              = '127.0.0.1',
  Stdlib::Host                $redis_hostname             = $hostname,
  Boolean                     $redis_manage_repo          = false,
  String                      $redis_password             = undef,
  Stdlib::Port                $redis_port                 = 6379,
  St2::Repository             $repository                 = $st2::params::repository,
  Integer[1]                  $rulesengine_num            = 1,
  Integer[1]                  $scheduler_gc_interval      = 10,
  Integer[1]                  $scheduler_num              = 1,
  Integer[1]                  $scheduler_pool_size        = 10,
  Float                       $scheduler_sleep_interval   = 0.1,
  Stdlib::Absolutepath        $ssh_key_location           = '/home/stanley/.ssh/st2_stanley_key',
  String                      $ssl_cert                   = "${ssl_dir}/st2.crt",
  Boolean                     $ssl_cert_manage            = true,
  Stdlib::Absolutepath        $ssl_dir                    = '/etc/ssl/st2',
  String                      $ssl_key                    = "${ssl_dir}/st2.key",
  Stdlib::Port                $stream_port                = 9102,
  String[1]                   $syslog_facility            = 'local7',
  Boolean                     $syslog                     = false,
  Stdlib::Host                $syslog_host                = 'localhost',
  Stdlib::Port                $syslog_port                = 514,
  Enum['tcp', 'udp']          $syslog_protocol            = 'udp',
  Boolean                     $timersengine_enabled       = true,
  String[1]                   $timersengine_timezone      = 'America/New_York',
  Boolean                     $use_ssl                    = false,
  Boolean                     $validate_output_schema     = false,
  St2::Ensure                 $version                    = 'present',
  Stdlib::Absolutepath        $web_root                   = '/opt/stackstorm/static/webui',
  Integer[1]                  $workflowengine_num         = 1,
) inherits st2::params {
  ########################################
  ## Control commands
  exec { '/usr/bin/st2ctl reload --register-all':
    tag         => 'st2::reload',
    refreshonly => true,
  }

  exec { '/usr/bin/st2ctl reload --register-configs':
    tag         => 'st2::register-configs',
    refreshonly => true,
  }
}
