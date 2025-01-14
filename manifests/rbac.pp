# @summary This defined type creates RBAC resources for users
#
# @note This is an enterprise feature, and requires a license to be used.

# @param ensure
#   Ensure state of the user. Default present.
# @param user
#   The username of the user. Default is the title of the resource.
# @param description
#   Description of the user. Default is "Created and managed by Puppet".
# @param roles
#   An array of roles to assign to the user. Default is an empty array.
#
# @example
#   st2::rbac { 'admin':
#     description => "Administrative user",
#     roles       => [
#       'observer',
#       'my_test_role',
#     ],
#   }
define st2::rbac (
  St2::Ensure    $ensure       = 'present',
  String         $user         = $name,
  String         $description  = 'Created and managed by Puppet',
  Array[String]  $roles        = [],
) {
  #
  $_rbac_dir = '/opt/stackstorm/rbac'
  $_enabled_state = $ensure ? {
    'present' => true,
    default   => false,
  }

  ensure_resource('file', $_rbac_dir,
    {
      'ensure'  => 'directory',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0755',
      'require' => Class['st2::profile::server'],
    }
  )

  ensure_resource('file', "${_rbac_dir}/assignments",
    {
      'ensure'  => 'directory',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0755',
      'require' => Class['st2::profile::server'],
    }
  )

  ensure_resource('file', "${_rbac_dir}/roles",
    {
      'ensure'  => 'directory',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0755',
      'require' => Class['st2::profile::server'],
    }
  )

  ensure_resource('file', "${_rbac_dir}/assignments",
    {
      'ensure'  => 'directory',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0755',
      'require' => Class['st2::profile::server'],
    }
  )

  ensure_resource('exec', 'reload st2 rbac definitions',
    {
      'command'         => 'st2-apply-rbac-definitions',
      'refreshonly'     => true,
      'path'            => '/usr/sbin:/usr/bin:/sbin:/bin',
    }
  )

  file { "${_rbac_dir}/assignments/${user}.yaml":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('st2/rbac/assignments/user.yaml.epp',
      {
        user          => $user,
        description   => $description,
        roles         => $roles,
        enabled_state => $_enabled_state,
      }
    ),
    notify  => Exec['reload st2 rbac definitions'],
  }
}
