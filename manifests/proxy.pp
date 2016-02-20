# == Class: authservices::proxy
#
# Full description of class webproxy here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'authservices::proxy':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2016 Your name here, unless otherwise noted.
#
class authservices::proxy (
  $basehostname         = 'example.net',
  $web_pool = undef,
  $api_pool = undef,
){

  validate_string($basehostname)
  validate_array($web_pool)
  validate_array($api_pool)

  include nginx

  # Upstream server pools
  nginx::resource::upstream { 'authservicesweb':
    members => $web_pool,
  }
  nginx::resource::upstream { 'authservicesapi':
    members => $api_pool,
  }

  # VHosts
  nginx::resource::vhost { "${basehostname}":
    proxy => 'http://authservicesweb',
  }
  nginx::resource::vhost { "api.${basehostname}":
    proxy => 'http://authservicesapi',
  }

  # Locations
  nginx::resource::location { '~ /api/(.*)':
    vhost       => $basehostname,
    proxy       => 'http://authservicesapi/$1',
    raw_prepend => 'error_page 502 = @apidown;',
  }
  nginx::resource::location { '@apidown':
    vhost         => $basehostname,
    www_root      => '/srv/empty',
    rewrite_rules => ["^/api/(.*)\$ http://api.${basehostname}/\$1 redirect"],
  }

  File['/etc/nginx/sites-available'] -> Nginx::Resource::Upstream<| |>
  File['/etc/nginx/sites-available'] -> Nginx::Resource::Vhost<| |>
  File['/etc/nginx/sites-available'] -> Nginx::Resource::Location<| |>

  File['/etc/nginx/sites-enabled'] -> Nginx::Resource::Upstream<| |>
  File['/etc/nginx/sites-enabled'] -> Nginx::Resource::Vhost<| |>
  File['/etc/nginx/sites-enabled'] -> Nginx::Resource::Location<| |>

}
