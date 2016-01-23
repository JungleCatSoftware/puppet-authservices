class authservices::web {
  include nginx

  file { '/srv/htdocs':
    ensure => directory,
  } ->
  file { '/srv/htdocs/accounttest.txt':
    ensure  => file,
    content => "Successfully reached ACCOUNTS\n",
  } ->
  nginx::resource::vhost { 'accounts':
    www_root => '/srv/htdocs',
    listen_port => 3000,
  }

}
