# === Class: teleport::install
#
# Installs teleport
class teleport::install(
  Enum[present, absent] $ensure = present,
) {

  $rootgroup = $facts['os']['family'] ? {
    'Solaris'          => 'wheel',
    /(Darwin|FreeBSD)/ => 'wheel',
    default            => 'root',
  }

  $teleport_current_path = '/opt/teleport-current.tar.gz'

  $directory_ensure = $ensure ? {
    present => directory,
    absent => absent,
  }
  $link_ensure = $ensure ? {
    present => link,
    absent => absent,
  }

  file { $teleport::bin_dir:
    ensure => $directory_ensure,
  } ->
  file { $teleport::extract_path:
    ensure => $directory_ensure,
  } ->
  exec { 'download-teleport-latest':
    command => "/usr/bin/aws s3 --region=${::region} cp ${teleport::archive_url} ${teleport_current_path}",
    unless => "/usr/bin/sha256sum ${teleport_current_path} | /bin/grep -q ${teleport::archive_sha256}"
  } ~>
  exec { 'extract-teleport-current':
    refreshonly => true,
    command => "/bin/tar xf ${teleport_current_path} -C ${teleport::extract_path} &&
    chown root:root ${teleport::extract_path}/teleport/tctl &&
    chown root:root ${teleport::extract_path}/teleport/teleport &&
    chown root:root ${teleport::extract_path}/teleport/tsh"
  } ->
  file {
    "${teleport::bin_dir}/tctl":
      ensure => $link_ensure,
      target => "${teleport::extract_path}/teleport/tctl";
    "${teleport::bin_dir}/teleport":
      ensure => $link_ensure,
      target => "${teleport::extract_path}/teleport/teleport";
    "${teleport::bin_dir}/tsh":
      ensure => $link_ensure,
      target => "${teleport::extract_path}/teleport/tsh";
    $teleport::assets_dir:
      ensure => $link_ensure,
      target => "${teleport::extract_path}/teleport/app"
  }
}
