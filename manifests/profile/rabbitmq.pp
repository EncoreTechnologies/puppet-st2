# @summary StackStorm compatable installation of RabbitMQ and dependencies.
#
# @param username
#   User to create within RabbitMQ for authentication.
# @param password
#   Password of +username+ for RabbitMQ authentication.
# @param port
#   Port to bind to for the RabbitMQ server
# @param bind_ip
#   IP address to bind to for the RabbitMQ server
# @param vhost
#   RabbitMQ virtual host to create for StackStorm
# @param erlang_url
#   URL to the Erlang repository to install from
# @param erlang_key
#   GPG key to verify the Erlang repository
# @param erlang_key_id
#   ID of the GPG key to verify the Erlang repository
# @param erlang_key_source
#   Source of the GPG key to verify the Erlang repository
# @param erlang_packages
#   List of Erlang packages to install
# @param erlang_rhel_sslcacert_location
#   Location of the SSL CA certificate for Erlang on RHEL
# @param erlang_rhel_sslverify
#   Whether to verify the SSL certificate for Erlang on RHEL
# @param erlang_rhel_gpgcheck
#   Whether to check the GPG signature for Erlang on RHEL
# @param erlang_rhel_repo_gpgcheck
#   Whether to check the GPG signature for the Erlang repository on RHEL
# @param manage_epel_repo
#   Whether to manage the EPEL repository on RHEL
#
# @example Basic Usage
#   include st2::profile::rabbitmq
#
# @example Authentication enabled (configured vi st2)
#   class { 'st2':
#     rabbitmq_username => 'rabbitst2',
#     rabbitmq_password => 'secret123',
#   }
#   include st2::profile::rabbitmq
#
class st2::profile::rabbitmq (
  String[1]                 $username                       = $st2::rabbitmq_username,
  String[1]                 $password                       = $st2::rabbitmq_password,
  Stdlib::Port              $port                           = $st2::rabbitmq_port,
  Stdlib::IP::Address       $bind_ip                        = $st2::rabbitmq_bind_ip,
  String                    $vhost                          = $st2::rabbitmq_vhost,
  Stdlib::HTTPUrl           $erlang_url                     = $st2::erlang_url,
  String                    $erlang_key                     = $st2::erlang_key,
  String                    $erlang_key_id                  = $st2::erlang_key_id,
  String                    $erlang_key_source              = $st2::erlang_key_source,
  Array[String[1]]          $erlang_packages                = $st2::erlang_packages,
  Stdlib::Absolutepath      $erlang_rhel_sslcacert_location = $st2::erlang_rhel_sslcacert_location,
  Variant[Boolean,Integer]  $erlang_rhel_sslverify          = $st2::erlang_rhel_sslverify,
  Variant[Boolean,Integer]  $erlang_rhel_gpgcheck           = $st2::erlang_rhel_gpgcheck,
  Variant[Boolean,Integer]  $erlang_rhel_repo_gpgcheck      = $st2::erlang_rhel_repo_gpgcheck,
  Boolean                   $manage_epel_repo               = $st2::manage_epel_repo,
) inherits st2 {
  #
  # RHEL 8 Requires another repo in addition to epel to be installed
  if ($facts['os']['family'] == 'RedHat') {
    $repos_ensure = true

    # This is required because when using the latest version of rabbitmq because the latest version in EPEL
    # for Erlang is 22.0.7 which is not compatible: https://www.rabbitmq.com/which-erlang.html
    yumrepo { 'erlang':
      ensure        => present,
      name          => 'rabbitmq_erlang',
      descr         => 'RabbitMQ Erlang',
      baseurl       => $erlang_url,
      gpgkey        => $erlang_key,
      enabled       => 1,
      gpgcheck      => $erlang_rhel_gpgcheck,
      repo_gpgcheck => $erlang_rhel_repo_gpgcheck,
      before        => Class['rabbitmq::repo::rhel'],
      sslverify     => $erlang_rhel_sslverify,
      sslcacert     => $erlang_rhel_sslcacert_location,
    }
  } elsif ($facts['os']['family'] == 'Debian') {
    $repos_ensure = true
    # trusty, xenial, bionic, etc
    $release = downcase($facts['os']['distro']['codename'])
    $repos = 'main'

    apt::source { 'erlang':
      ensure   => 'present',
      location => $erlang_url,
      release  => $release,
      repos    => $repos,
      pin      => '1000',
      key      => {
        'id'     => $erlang_key_id,
        'source' => $erlang_key_source,
      },
      notify   => Exec['apt-get-clean'],
      tag      => ['st2::rabbitmq::sources'],
    }

    # rebuild apt cache since we just changed repositories
    # Executing it manually here to avoid dep cycles
    exec { 'apt-get-clean':
      command     => '/usr/bin/apt-get -y clean',
      refreshonly => true,
      notify      => Exec['apt-get-update'],
    }

    exec { 'apt-get-update':
      command     => '/usr/bin/apt-get -y update',
      refreshonly => true,
    }

    ensure_packages([$erlang_packages],
      {
        ensure  => 'present',
        tag     => ['st2::packages', 'st2::rabbitmq::packages'],
        require => Exec['apt-get-update'],
      }
    )
  } else {
    $repos_ensure = false
  }

  # In new versions of the RabbitMQ module we need to explicitly turn off
  # the ranch TCP settings so that Kombu can connect via AMQP
  class { 'rabbitmq' :
    config_ranch          => false,
    repos_ensure          => $repos_ensure,
    delete_guest_user     => true,
    port                  => $port,
    environment_variables => {
      'RABBITMQ_NODE_IP_ADDRESS' => $st2::rabbitmq_bind_ip,
    },
    manage_python         => false,
    require_epel          => $manage_epel_repo,
  }

  contain 'rabbitmq'

  rabbitmq_user { $username:
    admin    => true,
    password => $password,
  }

  rabbitmq_vhost { $vhost:
    ensure => present,
  }

  rabbitmq_user_permissions { "${username}@${vhost}":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  }

  # RHEL needs EPEL installed prior to rabbitmq
  if (($facts['os']['family'] == 'RedHat') and ($manage_epel_repo == true)) {
    Class['epel']
    -> Class['rabbitmq']

    Yumrepo['epel']
    -> Class['rabbitmq']
    -> Package['rabbitmq-server']
  } elsif $facts['os']['family'] == 'Debian' {
    # Debian/Ubuntu needs erlang before rabbitmq
    Package<| tag == 'st2::rabbitmq::packages' |>
    -> Class['rabbitmq']
  }
}
