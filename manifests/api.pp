class authservices::api {

  file { '/etc/authservicesapi.conf':
    ensure  => file,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0444',
    content => '{
  "cassandra": {
    "nodes": [ "10.10.1.25" ]
  }
}
',
    notify => Service['gunicorn'],
  }

  authservices::pythonwebapp { 'authservicesapi':
    codesource => '/vagrant/src/AuthServices-API',
    bind       => '0.0.0.0:3001',
  }

}
