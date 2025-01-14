# @summary Install and configure st2 packages in bulk and via Hiera.
#
# @see st2::pack and st2::pack::config for usage
#
# @param packs
#   A hash of pack names and their configurations. The key is the pack name and the value is a hash of
#   configuration options. See st2::pack and st2::pack::config for more information.
#
# @example Basic Usage
#  class { 'st2::packs':
#    packs => {
#      puppet => {},
#      influxdb => {
#        config => {
#          server => 'influxdb.domain.tld',
#      },
#    },
#  }
#
# @example Created via Hiera
#  st2::packs:
#    puppet: {}
#    influxdb:
#      config:
#        server => 'influxdb.domain.tld'
#
class st2::packs (
  Variant[String, Hash]   $packs = $st2::packs,
) inherits st2 {
  #
  create_resources('st2::pack', $packs)
}
