define authservices::pythonwebapp (
  $appname      = $name,
  $bind         = undef,
  $codesource   = undef,
  $venvpath     = "/srv/${name}"
) {

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
    dev        => present,
    virtualenv => present,
    gunicorn   => present,
  }

  package { 'python3.4-venv':
    ensure => installed,
  }

  package { 'build-essential':
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

  python::requirements { "${codesource}/requirements.txt":
    virtualenv             => $venvpath,
    owner                  => 'www-data',
    group                  => 'www-data',
    fix_requirements_owner => false,
  }

  python::gunicorn { $appname:
    ensure     => present,
    bind       => $bind,
    virtualenv => $venvpath,
    dir        => $codesource,
    appmodule  => "${appname}:app",
  }

  Package['python'] -> Package['python3.4-venv'] -> Python::Pyvenv<| |>

  Package['build-essential'] -> Python::Pip<| |>
  Package['build-essential'] -> Python::Requirements<| |>

  Python::Pyvenv[$venvpath] -> Python::Pip<| virtualenv == $venvpath |>
  Python::Pyvenv[$venvpath] -> Python::Requirements<| virtualenv == $venvpath |>
  Python::Pip<| virtualenv == $venvpath |> -> Python::Gunicorn<| virtualenv == $venvpath |>
  Python::Requirements<| virtualenv == $venvpath |> -> Python::Gunicorn<| virtualenv == $venvpath |>
}
