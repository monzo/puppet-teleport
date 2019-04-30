# === Class: teleport::install
#
# Installs teleport
class teleport::install(
  Enum[present, absent] $ensure = present,
) {

  include ::archive

  $rootgroup = $facts['os']['family'] ? {
    'Solaris'          => 'wheel',
    /(Darwin|FreeBSD)/ => 'wheel',
    default            => 'root',
  }

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
  archive { $teleport::archive_path:
    ensure        => $ensure,
    extract       => true,
    extract_path  => $teleport::extract_path,
    source        => $teleport::archive_url,
    creates       => "${teleport::extract_path}/teleport"
    checksum      => $teleport::checksum,
    checksum_type => $teleport::checksum_type,
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
