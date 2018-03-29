#!/usr/bin/env bash

opts=( )

# server.http.port
# The HTTP port to use for the server
RDECK_SERVER_HTTP_PORT="${RDECK_SERVER_HTTP_PORT:-4440}"
[[ -n "$RDECK_SERVER_HTTP_PORT" ]] && opts=( "${opts[@]}" "-Dserver.http.port=${RDECK_SERVER_HTTP_PORT}" )

# server.https.port
# The HTTPS port to use or the server
RDECK_SERVER_HTTPS_PORT="${RDECK_SERVER_HTTPS_PORT:-4443}"
[[ -n "$RDECK_SERVER_HTTPS_PORT" ]] && opts=( "${opts[@]}" "-Dserver.https.port=${RDECK_SERVER_HTTPS_PORT}" )

# server.http.host
# Address/hostname to listen on
RDECK_SERVER_HTTP_HOST="${RDECK_SERVER_HTTP_HOST:-127.0.0.1}"
[[ -n "$RDECK_SERVER_HTTP_HOST" ]] && opts=( "${opts[@]}" "-Dserver.http.host=${RDECK_SERVER_HTTP_HOST}" )

# server.hostname
# Hostname to use for the server
RDECK_SERVER_HOSTNAME="${RDECK_SERVER_HOSTNAME:-Pesto.attlocal.net}"
[[ -n "$RDECK_SERVER_HOSTNAME" ]] && opts=( "${opts[@]}" "-Dserver.hostname=${RDECK_SERVER_HOSTNAME}" )

# server.web.context
# Web context path to use, such as "/rundeck"
RDECK_SERVER_WEB_CONTEXT="${RDECK_SERVER_WEB_CONTEXT:-/}"
[[ -n "$RDECK_SERVER_WEB_CONTEXT" ]] && opts=( "${opts[@]}" "-Dserver.web.context=${RDECK_SERVER_WEB_CONTEXT}" )

# rdeck.base
# Rundeck Basedir to use
RDECK_RDECK_BASE="${RDECK_RDECK_BASE:-$(brew --prefix)/var/rundeck}"
[[ -n "$RDECK_RDECK_BASE" ]] && opts=( "${opts[@]}" "-Drdeck.base=${RDECK_RDECK_BASE}" )

# server.datastore.path
# Path to server datastore dir
RDECK_SERVER_DATASTORE_PATH="${RDECK_SERVER_DATASTORE_PATH:-$(brew --prefix)/var/db/rundeck}"
[[ -n "$RDECK_SERVER_DATASTORE_PATH" ]] && opts=( "${opts[@]}" "-Dserver.datastore.path=${RDECK_SERVER_DATASTORE_PATH}" )

# default.user.name
# Username for default user account to create
RDECK_DEFAULT_USER_NAME="${RDECK_DEFAULT_USER_NAME:-admin}"
[[ -n "$RDECK_DEFAULT_USER_NAME" ]] && opts=( "${opts[@]}" "-Ddefault.user.name=${RDECK_DEFAULT_USER_NAME}" )

# default.user.password
# Password for default user account to create
RDECK_DEFAULT_USER_PASSWORD="${RDECK_DEFAULT_USER_PASSWORD:-admin}"
[[ -n "$RDECK_DEFAULT_USER_PASSWORD" ]] && opts=( "${opts[@]}" "-Ddefault.user.password=${RDECK_DEFAULT_USER_PASSWORD}" )

# rundeck.jaaslogin
# if true, enable JAAS login, otherwise use the realm.properties file for login information
RDECK_RUNDECK_JAASLOGIN="${RDECK_RUNDECK_JAASLOGIN:-false}"
[[ -n "$RDECK_RUNDECK_JAASLOGIN" ]] && opts=( "${opts[@]}" "-Drundeck.jaaslogin=${RDECK_RUNDECK_JAASLOGIN}" )

# loginmodule.name
# Custom JAAS loginmodule name to use
RDECK_LOGINMODULE_NAME="${RDECK_LOGINMODULE_NAME:-}"
[[ -n "$RDECK_LOGINMODULE_NAME" ]] && opts=( "${opts[@]}" "-Dloginmodule.name=${RDECK_LOGINMODULE_NAME}" )

# loginmodule.conf.name
# Name of a custom JAAS config file, located in the server's config dir.
RDECK_LOGINMODULE_CONF_NAME="${RDECK_LOGINMODULE_CONF_NAME:-}"
[[ -n "$RDECK_LOGINMODULE_CONF_NAME" ]] && opts=( "${opts[@]}" "-Dloginmodule.conf.name=${RDECK_LOGINMODULE_CONF_NAME}" )

# rundeck.config.name
# Name of a custom rundeck config file, located in the server's config dir.
RDECK_RUNDECK_CONFIG_NAME="${RDECK_RUNDECK_CONFIG_NAME:-}"
[[ -n "$RDECK_RUNDECK_CONFIG_NAME" ]] && opts=( "${opts[@]}" "-Drundeck.config.name=${RDECK_RUNDECK_CONFIG_NAME}" )

# rundeck.ssl.config
# Path to the SSL config properties file to enable SSL. If not set, SSL is not enabled.
RDECK_RUNDECK_SSL_CONFIG="${RDECK_RUNDECK_SSL_CONFIG:-}"
[[ -n "$RDECK_RUNDECK_SSL_CONFIG" ]] && opts=( "${opts[@]}" "-Drundeck.ssl.config=${RDECK_RUNDECK_SSL_CONFIG}" )

# rundeck.jetty.connector.forwarded
# Set to true to enable support for "X-forwarded-*" headers which may be sent by a front-end proxy to the rundeck server (see "Using an SSL Terminated Proxy")
RDECK_RUNDECK_JETTY_CONNECTOR_FORWARDED="${RDECK_RUNDECK_JETTY_CONNECTOR_FORWARDED:-false}"
[[ -n "$RDECK_RUNDECK_JETTY_CONNECTOR_FORWARDED" ]] && opts=( "${opts[@]}" "-Drundeck.jetty.connector.forwarded=${RDECK_RUNDECK_JETTY_CONNECTOR_FORWARDED}" )

# rundeck.jetty.connector.ssl.excludedProtocols
# Comma-separated list of SSL protocols to disable (see Disabling SSL Protocols)
RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDPROTOCOLS="${RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDPROTOCOLS:-SSLv3}"
[[ -n "$RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDPROTOCOLS" ]] && opts=( "${opts[@]}" "-Drundeck.jetty.connector.ssl.excludedProtocols=${RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDPROTOCOLS}" )

# rundeck.jetty.connector.ssl.includedProtocols
# Comma-separated list of SSL protocols to include (see Disabling SSL Protocols)
RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDPROTOCOLS="${RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDPROTOCOLS:-}"
[[ -n "$RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDPROTOCOLS" ]] && opts=( "${opts[@]}" "-Drundeck.jetty.connector.ssl.includedProtocols=${RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDPROTOCOLS}" )

# rundeck.jetty.connector.ssl.excludedCipherSuites
# Comma-separated list of Cipher suites to disable (see Disabling SSL Protocols)
RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDCIPHERSUITES="${RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDCIPHERSUITES:-}"
[[ -n "$RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDCIPHERSUITES" ]] && opts=( "${opts[@]}" "-Drundeck.jetty.connector.ssl.excludedCipherSuites=${RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDCIPHERSUITES}" )

# rundeck.jetty.connector.ssl.includedCipherSuites
# Comma-separated list of Cipher suites to enable (see Disabling SSL Protocols)
RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDCIPHERSUITES="${RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDCIPHERSUITES:-}"
[[ -n "$RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDCIPHERSUITES" ]] && opts=( "${opts[@]}" "-Drundeck.jetty.connector.ssl.includedCipherSuites=${RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDCIPHERSUITES}" )

JAVA_HOME="$(/usr/libexec/java_home -v 1.8)" exec java \
  "${opts[@]}" \
  -jar "#{libexec}/rundeck-launcher-#{version}.jar" \
"$@"
