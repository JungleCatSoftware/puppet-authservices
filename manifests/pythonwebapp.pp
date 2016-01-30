define authservices::pythonwebapp (
  $appname    = $name,
  $codesource = undef,
  $bind       = undef,
) {

  validate_string($appname)
  validate_string($codesource)
  validate_string($bind)

  if ! $codesource {
    fail("authservices::pythonwebapp::codesource is undefined")
  }

  if ! $bind {
    fail("authservices::pythonwebapp::bind is undefined")
  }

  $venvpath = "/srv/${name}"

  class { 'python':
    version    => '3.4',
    pip        => present,
    virtualenv => present,
    gunicorn   => present,
  }

  Package['python'] ->
  package { 'python3.4-venv':
    ensure => installed,
  } -> Python::Pyvenv <| |>

  python::pyvenv { $venvpath:
    ensure     => present,
    version    => '3.4',
    owner      => 'www-data',
    group      => 'www-data',
  } ->
  python::pip { 'gunicorn':
    ensure     => '17.5',
    virtualenv => $venvpath,
  } ->
  python::gunicorn { $name:
    ensure     => present,
    bind       => $bind,
    virtualenv => $venvpath,
    dir        => $codesource,
    appmodule  => "${name}:app",
  }
}
