#!/usr/bin/env perl

# Launch Rundeck server; you can set options in $(brew --prefix)/etc/rundeck.conf

# Perl 5.18 was released in 2014, and it's reasonable to expect a perl no more than 4 years old
use 5.018;
use Carp;

my $brew_prefix     = determine_brew_prefix();
my $rundeck_version = $ENV{RUNDECK_VERSION} || "#{version}";
my $jarfile         = "${brew_prefix}/libexec/rundeck-launcher-${rundeck_version}.jar";

my @java_options;
my $defaults = {
  RDECK_DEFAULT_USER_NAME => $ENV{USER} || 'admin',
  RDECK_SERVER_HOSTNAME   => "localhost",
  RDECK_SERVER_HTTP_HOST  => "127.0.0.1",
  RDECK_SERVER_HTTP_PORT  => 4440,
};
my $env_vars = {
  RDECK_DEFAULT_USER_NAME                                => "default.user.name",
  RDECK_DEFAULT_USER_PASSWORD                            => "default.user.password",
  RDECK_LOGINMODULE_CONF_NAME                            => "loginmodule.conf.name",
  RDECK_LOGINMODULE_NAME                                 => "loginmodule.name",
  RDECK_RDECK_BASE                                       => "rdeck.base",
  RDECK_RUNDECK_CONFIG_NAME                              => "rundeck.config.name",
  RDECK_RUNDECK_JAASLOGIN                                => "rundeck.jaaslogin",
  RDECK_RUNDECK_JETTY_CONNECTOR_FORWARDED                => "rundeck.jetty.connector.forwarded",
  RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDCIPHERSUITES => "rundeck.jetty.connector.ssl.excludedCipherSuites",
  RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDPROTOCOLS    => "rundeck.jetty.connector.ssl.excludedProtocols",
  RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDCIPHERSUITES => "rundeck.jetty.connector.ssl.includedCipherSuites",
  RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDPROTOCOLS    => "rundeck.jetty.connector.ssl.includedProtocols",
  RDECK_RUNDECK_SSL_CONFIG                               => "rundeck.ssl.config",
  RDECK_SERVER_DATASTORE_PATH                            => "server.datastore.path",
  RDECK_SERVER_HOSTNAME                                  => "server.hostname",
  RDECK_SERVER_HTTPS_PORT                                => "server.https.port",
  RDECK_SERVER_HTTP_HOST                                 => "server.http.host",
  RDECK_SERVER_HTTP_PORT                                 => "server.http.port",
  RDECK_SERVER_WEB_CONTEXT                               => "server.web.context",
};

sub determine_brew_prefix {
  open my $brew, "-|", "brew", "--prefix" or croak $!;
  my $prefix=do { local $/; <$brew> };
  close $brew;
  chomp $prefix;
  croak "brew --prefix: failed to give valid prefix" unless defined $prefix and length $prefix;
  croak sprintf "%s: brew --prefix: directory not found", $prefix unless -d $prefix;
  return $prefix;
}

sub read_conf_file {
  my $file=shift;
  croak sprintf "%s: config file not found", $file unless -f $file;
  open my $input, "<", $file or croak sprintf "%s: config file could not be opened for reading: %s", $file, $!;
}

#use JSON::MaybeXS;
#print JSON->new->pretty->canonical->encode({brew_prefix => $brew_prefix, rundeck_version => $rundeck_version, jarfile => $jarfile, env_vars => $env_vars});

__END__

BREW_PREFIX="$(brew --prefix)" || exit $?
jarfile="#{prefix}/libexec/rundeck-launcher-#{version}.jar"

# Get options from ${BREW_PREFIX}/etc/rundeck.conf

declare -a opts
declare -a vars

export JAVA_HOME

RDECK_RDECK_BASE="${BREW_PREFIX}/var/rundeck"

# Default settings to pass to Rundeck
# shellcheck disable=SC2034
{
  RDECK_DEFAULT_USER_NAME="${USER:-admin}"
  RDECK_SERVER_HOSTNAME="localhost"
  RDECK_SERVER_HTTP_HOST=127.0.0.1
  RDECK_SERVER_HTTP_PORT=4440
}

if [[ -f "${BREW_PREFIX}/etc/rundeck.conf" ]]; then
  # shellcheck disable=SC1090
  source "${BREW_PREFIX}/etc/rundeck.conf" || exit $?
fi

# for a given pair of option name and variable name, add the option
# to the list of options, only if the named variable is not undefined or empty
add_opt_for_var() {
  local opt var
  while [[ $# -gt 1 ]]; do
    opt="$1"; var="$2"; shift 2
    if [[ -n "${!var}" ]]; then
      opts=( "${opts[@]}" "-D${opt}=${!var}" )
    fi
    vars=( "${vars[@]}" "$var" )
  done
}

# shellcheck disable=SC2153
debug() {
  declare -p -v "${vars[@]}"
}

debug_exec() {
  if [[ -n "$RDECK_SERVER_SCRIPT_DEBUG" ]]; then
    printf 1>&2 '%q ' "$@"; printf 1>&2 '\n'
  fi
  if [[ "$RDECK_SERVER_SCRIPT_DEBUG" != 'dryrun' ]]; then
    exec "$@"
  else
    printf 1>&2 '\e[31m%s: not actually running server due to dryrun mode\e[0m\n' "$(basename -- "$0")"
  fi
}

add_opt_for_var \
  server.http.port       RDECK_SERVER_HTTP_PORT       \
  server.https.port      RDECK_SERVER_HTTPS_PORT      \
  server.http.host       RDECK_SERVER_HTTP_HOST       \
  server.hostname        RDECK_SERVER_HOSTNAME        \
  server.web.context     RDECK_SERVER_WEB_CONTEXT     \
  rdeck.base             RDECK_RDECK_BASE             \
  server.datastore.path  RDECK_SERVER_DATASTORE_PATH  \
  default.user.name      RDECK_DEFAULT_USER_NAME      \
  default.user.password  RDECK_DEFAULT_USER_PASSWORD  \
  rundeck.jaaslogin      RDECK_RUNDECK_JAASLOGIN      \
  loginmodule.name       RDECK_LOGINMODULE_NAME       \
  loginmodule.conf.name  RDECK_LOGINMODULE_CONF_NAME  \
  rundeck.config.name    RDECK_RUNDECK_CONFIG_NAME    \
  rundeck.ssl.config     RDECK_RUNDECK_SSL_CONFIG     \
  rundeck.jetty.connector.forwarded RDECK_RUNDECK_JETTY_CONNECTOR_FORWARDED \
  rundeck.jetty.connector.ssl.excludedProtocols RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDPROTOCOLS \
  rundeck.jetty.connector.ssl.includedProtocols RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDPROTOCOLS \
  rundeck.jetty.connector.ssl.excludedCipherSuites RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDCIPHERSUITES \
  rundeck.jetty.connector.ssl.includedCipherSuites RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDCIPHERSUITES

if [[ -n "$RDECK_SERVER_SCRIPT_DEBUG" ]]; then
  debug
fi

cd "$RDECK_RDECK_BASE" || exit $?

JAVA_HOME="$(/usr/libexec/java_home -v 1.8)" || exit $?

if [[ -z "$JAVA_HOME" ]] || [[ ! -d "$JAVA_HOME" ]]; then
  printf 1>&2 '%s %s: java home directory not found\n' "$0" "$JAVA_HOME"
  exit 3
fi

debug_exec java "${opts[@]}" -jar "$jarfile" "-b" "${BREW_PREFIX}/var/rundeck" "$@"

