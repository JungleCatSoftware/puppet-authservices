class authservices::web {

  authservices::pythonwebapp { 'authservicesweb':
    codesource => '/vagrant/src/AuthServices-Web',
    bind       => '0.0.0.0:3000',
  }

}
