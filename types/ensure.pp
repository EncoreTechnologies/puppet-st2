# Type: puppet-st2/ensure.pp
# Description: The ensure type for the st2 module.
# Reference: https://www.puppet.com/docs/puppet/7/types/package.html#package-attribute-ensure
# NOTE: See reference for information on using specific package versions.
# 
type St2::Ensure = Variant[Enum['present', 'absent', 'latest', 'installed'], String[1]]
