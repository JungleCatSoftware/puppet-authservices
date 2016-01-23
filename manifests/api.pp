class authservices::api {
  include nginx

  file { '/srv/htdocs':
    ensure => directory,
  } ->
  file { '/srv/htdocs/accountapitest.txt':
    ensure  => file,
    content => "Successfully reached ACCOUNTS-API\n",
  } ->
  nginx::resource::vhost { 'api':
    www_root => '/srv/htdocs',
    listen_port => 3001,
  }
}
