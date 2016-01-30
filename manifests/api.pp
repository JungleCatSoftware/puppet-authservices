class authservices::api {

  authservices::pythonwebapp { 'authservicesapi':
    codesource   => '/vagrant/src/AuthServices-API',
    bind         => '0.0.0.0:3001',
    include_rest => true,
  }

}
