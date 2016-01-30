define authservices::pythonwebapp (
  $appname      = $name,
  $bind         = undef,
  $codesource   = undef,
  $include_rest = false,
  $venvpath     = "/srv/${name}"
) {

  validate_bool($include_rest)

  validate_string($appname)
  validate_string($bind)
  validate_string($codesource)
  validate_string($venvpath)

  if ! $codesource {
    fail('authservices::pythonwebapp::codesource is undefined')
  }
  if ! $bind {
    fail('authservices::pythonwebapp::bind is undefined')
  }


  class { 'python':
    version    => '3.4',
    pip        => present,
    virtualenv => present,
    gunicorn   => present,
  }

  package { 'python3.4-venv':
    ensure => installed,
  }

  python::pyvenv { $venvpath:
    ensure  => present,
    version => '3.4',
    owner   => 'www-data',
    group   => 'www-data',
  }

  python::pip { 'gunicorn':
    ensure     => '17.5',
    virtualenv => $venvpath,
  }
  python::pip { 'flask':
    ensure     => present,
    virtualenv => $venvpath,
  }

  if $include_rest {
    python::pip { 'flask-restful':
      ensure     => present,
      virtualenv => $venvpath,
    }
  }

  python::gunicorn { $appname:
    ensure     => present,
    bind       => $bind,
    virtualenv => $venvpath,
    dir        => $codesource,
    appmodule  => "${appname}:app",
  }

  Package['python'] -> Package['python3.4-venv'] -> Python::Pyvenv<| |>

  Python::Pyvenv[$venvpath] -> Python::Pip<| virtualenv == $venvpath |>
  -> Python::Gunicorn<| virtualenv == $venvpath |>
}
