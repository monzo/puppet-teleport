# === Class teleport::config
#
# This class is called from teleport::init to install the config file
# and the service definition.
#
class teleport::config(
  Enum[present, absent] $ensure = present,
) {
  file { $teleport::config_path:
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
    content => template('teleport/teleport.yaml.erb')
  }
}
