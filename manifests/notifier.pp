# @summary Manages the <code>st2notifier</code> service (Orquesta)
#
# Normally this class is instantiated by +st2::profile::fullinstall+.
# However, advanced users can instantiate this class directly to configure
# and manage just the <code>st2notifier</code> service on a single node.
# Parameters for this class mirror the parameters in the st2 config.
#
# @see https://github.com/StackStorm/st2/blob/master/conf/st2.conf.sample
#
# @example Basic usage
#   include st2::notifier
#
# @param notifier_num
#   The number of notifiers to have in an active active state
# @param notifier_services
#   Name of all the notifier services
#
class st2::notifier (
  $notifier_num      = $st2::notifier_num,
  $notifier_services = $st2::params::notifier_services,
) inherits st2 {

  $_logger_config = $::st2::syslog ? {
    true    => 'syslog',
    default => 'logging',
  }

  ########################################
  ## Config
  ini_setting { 'notifier_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'notifier',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.notifier.conf",
    tag     => 'st2::config',
  }

  if ($notifier_num > 1) {
    $additional_services = range("2", "$notifier_num").reduce([]) |$memo, $number| {
      $notifier_name = "st2notifier${number}"
      case $facts['os']['family'] {
        'RedHat': {
          $file_path = '/usr/lib/systemd/system/'
        }
        'Debian': {
          $file_path = '/lib/systemd/system/'
        }
        default: {
          fail("Unsupported managed repository for osfamily: ${facts['os']['family']}, operatingsystem: ${facts['os']['name']}")
        }
      }

      systemd::unit_file { "${notifier_name}.service":
        path => $file_path,
        source => "${file_path}st2notifier.service",
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
      }

      $memo + [$notifier_name]
    }

    $_notifier_services = $notifier_services + $additional_services

  } else {
    $_notifier_services = $notifier_services
  }

  ########################################
  ## Services
  service { $_notifier_services:
    ensure => 'running',
    enable => true,
    tag    => 'st2::service',
  }
}
