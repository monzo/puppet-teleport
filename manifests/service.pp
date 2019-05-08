# == Class teleport::service
#
# This class is meant to be called from teleport::init
# It ensure the service is running
#
class teleport::service(
  Boolean $manage_service = true,
  Enum[present, absent] $ensure = present,
  String $init_style = 'systemd',
) {
  if $manage_service == true {
    case $init_style {
      'systemd': {
        file { $teleport::systemd_file:
          ensure  => $ensure,
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
          content => template('teleport/teleport.systemd.erb'),
        }~>
        exec { 'teleport-systemd-reload':
          command     => 'systemctl daemon-reload',
          path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
          refreshonly => true,
        }
      }
      'init': {
        file { '/etc/init.d/teleport':
          ensure  => $ensure,
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('teleport/teleport.init.erb')
        }
      }
      default: { fail('OS not supported') }
    }~>
    service { 'teleport':
      ensure   => $ensure ? {
        present => running,
        absent => stopped,
      },
      enable   => $teleport::service_enable,
      provider => $init_style,
      subscribe => [Exec['extract-teleport-current'], File["${teleport::bin_dir}/teleport"]],
    }
  }
}
