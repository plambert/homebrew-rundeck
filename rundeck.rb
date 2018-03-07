# WARNING: THIS IS A DEVELOPMENT-ONLY VERSION OF THIS FORMULA, IT DOES NOT WORK!

class Rundeck < Formula
  @@testing=true
  @@prebuilt=File.file?("#{ENV['HOME']}/rundeck.build.tgz")
  desc "Enable self-service access to existing scripts and tools."
  homepage "http://rundeck.org"
  local_url="file://#{ENV['HOME']}/rundeck.build.tgz"
  remote_url="https://github.com/rundeck/rundeck/archive/v2.10.6.tar.gz"

  if @@testing and @@prebuilt
    url local_url
    puts "==> Using #{local_url} in testing mode"
  else
    url remote_url
    sha256 "b6dde4ae74ad00a3c2fac3b05f894cf3e2d9e7e8e27a118e64d15813619f4458"
    puts "==> Using #{remote_url} in testing mode" if @@testing
  end
  version "2.10.6"
  depends_on :java => "1.8"
  def install
    # comment this line when testing
    if @@testing and @@prebuilt
      puts "==> using prebuilt tgz in testing mode"
    else
      puts "==> making app"
      system "make", "app"
    end
    if @@testing and ! @@prebuilt
      puts "==> creating prebuilt tgz in testing mode"
      system 'tar', '-czf', '~/rundeck.build.tgz', '--exclude', '.brew*', '.'
    end
    libexec.install "rundeck-launcher/launcher/build/libs/rundeck-launcher-#{version}.jar"
    (var/"rundeck").mkdir #/ # fix sublime text ruby parser
    (
      bin/"rundeck-server" #/ # fix sublime text ruby parser
    ).write <<~EOS
      #!/usr/bin/env bash
      
      # Launch Rundeck server

      # You can set options in $(brew --prefix)/etc/rundeck.conf
      
      BREW_PREFIX="$(brew --prefix)" || exit $?
      jarfile="#{prefix}/libexec/rundeck-launcher-#{version}.jar"
      
      # Get options from ${BREW_PREFIX}/etc/rundeck.conf
      
      declare -a opts

      RDECK_RDECK_BASE="${BREW_PREFIX}/var/rundeck"
      RDECK_SERVER_HOSTNAME="localhost"
      RDECK_SERVER_HTTP_HOST=127.0.0.1
      
      if [[ -f "${BREW_PREFIX}/etc/rundeck.conf" ]]; then
        source "${BREW_PREFIX}/etc/rundeck.conf" || exit $?
      fi
            
      add_opt_for_var() {
        local opt var
        while [[ $# -gt 1 ]]; do
          opt="$1"; var="$2"; shift 2
          [[ -n "${!var}" ]] && opts=( "${opts[@]}" "-D${opt}=${!var}" )
        done
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
      
      cd "$RDECK_RDECK_BASE" || exit $?
      
      export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)" || exit $?
      
      if [[ ! -n "$JAVA_HOME" ]] || [[ ! -d "$JAVA_HOME" ]]; then
        printf 1>&2 '%s %s: java home directory not found\n' "$0" "$JAVA_HOME"
        exit 3
      fi
      
      exec java "${opts[@]}" -jar "$jarfile" "-b" "${BREW_PREFIX}/var/rundeck" "$@"
      
    EOS
  end
  test do
    rc=0
    if File.file?('/usr/local/bin/shellcheck')
      system '/usr/local/bin/shellcheck', (bin/'rundeck-server') #/ # fix ruby syntax in sublime text
      raise $? if $? > 0
    end
    system 'bash', '-n', (bin/'rundeck-server') #/ # fix ruby syntax in sublime text
    raise $? if $? > 0
  end
end
