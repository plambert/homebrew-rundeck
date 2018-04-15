#!/usr/bin/env bash
      
# Launch Rundeck server

# You can set options in $(brew --prefix)/etc/rundeck.conf

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
  rundeck.jetty.connector.forwarded \
    RDECK_RUNDECK_JETTY_CONNECTOR_FORWARDED \
  rundeck.jetty.connector.ssl.excludedProtocols \
    RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDPROTOCOLS \
  rundeck.jetty.connector.ssl.includedProtocols \
    RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDPROTOCOLS \
  rundeck.jetty.connector.ssl.excludedCipherSuites \
    RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDCIPHERSUITES \
  rundeck.jetty.connector.ssl.includedCipherSuites \
    RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDCIPHERSUITES

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

