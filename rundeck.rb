# WARNING: THIS IS A DEVELOPMENT-ONLY VERSION OF THIS FORMULA, IT DOES NOT WORK!
require "English"

class Rundeck < Formula
  @version='2.11.4'
  @testing=true
  @prebuilt=File.file?("#{ENV["HOME"]}/rundeck.build.tgz")
  @url=nil
  @sha256={
    '2.11.4' => '0cfb4ae715301607ba2051f3e4a62945e42b781b4b52492c3e09f3139ad92265',
    '2.11.1' => '492e3b2be62c1d032ae91594f5aad6021319cad1519befbae8ab471b7807b12a'
  }
  desc "Enable self-service access to existing scripts and tools."
  homepage "http://rundeck.org"
  local_url="file://#{ENV["HOME"]}/rundeck.build.tgz"
  remote_url="https://github.com/rundeck/rundeck/archive/v#{@version}.tar.gz"

  if @testing && @prebuilt
    url local_url
    version @version
    @url=local_url
  else
    url remote_url
    sha256 @sha256[@version]
    @url=remote_url
  end
  depends_on :java => "1.8"
  def install
    # comment this line when testing
    if @testing && @prebuilt
      puts "==> using prebuilt tgz in testing mode"
      puts "==> Using #{@url} in testing mode"
    else
      puts "==> Building from #{@url}"
      system "make", "app"
    end
    if @testing && !@prebuilt
      puts "==> creating prebuilt tgz in testing mode"
      system "tar", "-czf", "~/rundeck.build.tgz", "--exclude", ".brew*", "."
    end
    libexec.install "rundeck-launcher/launcher/build/libs/rundeck-launcher-#{version}.jar"
    (var/"rundeck").mkdir unless (var/"rundeck").exist?
    (var/"log").install_symlink (var/"rundeck/server/logs") => "rundeck"
    (
      bin/"rundeck-server"
    ).write <<~EOS
      #!/usr/bin/env bash
            
      # Launch Rundeck server

      # You can set options in $(brew --prefix)/etc/rundeck.conf

      BREW_PREFIX="$(brew --prefix)" || exit $?
      jarfile="#{prefix}/libexec/rundeck-launcher-#{version}.jar"

      # Get options from ${BREW_PREFIX}/etc/rundeck.conf

      declare -a opts

      export JAVA_HOME

      RDECK_RDECK_BASE="${BREW_PREFIX}/var/rundeck"
      RDECK_SERVER_HOSTNAME="localhost"
      RDECK_SERVER_HTTP_HOST=127.0.0.1
      RDECK_SERVER_HTTP_PORT=4440

      if [[ -f "${BREW_PREFIX}/etc/rundeck.conf" ]]; then
        # shellcheck disable=SC1090
        source "${BREW_PREFIX}/etc/rundeck.conf" || exit $?
      fi
            
      add_opt_for_var() {
        local opt var
        while [[ $# -gt 1 ]]; do
          opt="$1"; var="$2"; shift 2
          [[ -n "${!var}" ]] && opts=( "${opts[@]}" "-D${opt}=${!var}" )
        done
      }

      # shellcheck disable=SC2153
      debug() {
        printf '%s=%q\\n' \\
          RDECK_DEFAULT_USER_NAME "$RDECK_DEFAULT_USER_NAME" \\
          RDECK_DEFAULT_USER_PASSWORD "$RDECK_DEFAULT_USER_PASSWORD" \\
          RDECK_LOGINMODULE_CONF_NAME "$RDECK_LOGINMODULE_CONF_NAME" \\
          RDECK_LOGINMODULE_NAME "$RDECK_LOGINMODULE_NAME" \\
          RDECK_RDECK_BASE "$RDECK_RDECK_BASE" \\
          RDECK_RUNDECK_CONFIG_NAME "$RDECK_RUNDECK_CONFIG_NAME" \\
          RDECK_RUNDECK_JAASLOGIN "$RDECK_RUNDECK_JAASLOGIN" \\
          RDECK_RUNDECK_JETTY_CONNECTOR_FORWARDED "$RDECK_RUNDECK_JETTY_CONNECTOR_FORWARDED" \\
          RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDCIPHERSUITES "$RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDCIPHERSUITES" \\
          RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDPROTOCOLS "$RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDPROTOCOLS" \\
          RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDCIPHERSUITES "$RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDCIPHERSUITES" \\
          RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDPROTOCOLS "$RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDPROTOCOLS" \\
          RDECK_RUNDECK_SSL_CONFIG "$RDECK_RUNDECK_SSL_CONFIG" \\
          RDECK_SERVER_DATASTORE_PATH "$RDECK_SERVER_DATASTORE_PATH" \\
          RDECK_SERVER_HOSTNAME "$RDECK_SERVER_HOSTNAME" \\
          RDECK_SERVER_HTTPS_PORT "$RDECK_SERVER_HTTPS_PORT" \\
          RDECK_SERVER_HTTP_HOST "$RDECK_SERVER_HTTP_HOST" \\
          RDECK_SERVER_HTTP_PORT "$RDECK_SERVER_HTTP_PORT" \\
          RDECK_SERVER_WEB_CONTEXT "$RDECK_SERVER_WEB_CONTEXT"

        printf 'Java Options:'
        printf ' %q' "${opts[@]}"
        printf '\\n'
      }

      add_opt_for_var \\
        server.http.port       RDECK_SERVER_HTTP_PORT       \\
        server.https.port      RDECK_SERVER_HTTPS_PORT      \\
        server.http.host       RDECK_SERVER_HTTP_HOST       \\
        server.hostname        RDECK_SERVER_HOSTNAME        \\
        server.web.context     RDECK_SERVER_WEB_CONTEXT     \\
        rdeck.base             RDECK_RDECK_BASE             \\
        server.datastore.path  RDECK_SERVER_DATASTORE_PATH  \\
        default.user.name      RDECK_DEFAULT_USER_NAME      \\
        default.user.password  RDECK_DEFAULT_USER_PASSWORD  \\
        rundeck.jaaslogin      RDECK_RUNDECK_JAASLOGIN      \\
        loginmodule.name       RDECK_LOGINMODULE_NAME       \\
        loginmodule.conf.name  RDECK_LOGINMODULE_CONF_NAME  \\
        rundeck.config.name    RDECK_RUNDECK_CONFIG_NAME    \\
        rundeck.ssl.config     RDECK_RUNDECK_SSL_CONFIG     \\
        rundeck.jetty.connector.forwarded \\
          RDECK_RUNDECK_JETTY_CONNECTOR_FORWARDED \\
        rundeck.jetty.connector.ssl.excludedProtocols \\
          RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDPROTOCOLS \\
        rundeck.jetty.connector.ssl.includedProtocols \\
          RDECK_RUNDECK_JETTY_CONNECTOR_SSL_INCLUDEDPROTOCOLS \\
        rundeck.jetty.connector.ssl.excludedCipherSuites \\
          RDECK_RUNDECK_JETTY_CONNECTOR_SSL_EXCLUDEDCIPHERSUITES \\
        rundeck.jetty.connector.ssl.includedCipherSuites \\
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

      exec java "${opts[@]}" -jar "$jarfile" "-b" "${BREW_PREFIX}/var/rundeck" "$@"

    EOS
  end
  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/rundeck-server</string>
          <string>-f</string>
        </array>
        <key>KeepAlive</key>
        <false/>
        <key>RunAtLoad</key>
        <true/>
        <key>StandardErrorPath</key>
        <string>/usr/local/var/log/rundeck</string>
        <key>StandardOutPath</key>
        <string>/usr/local/var/log/rundeck</string>
      </dict>
    </plist>
    EOS
  end
  def caveats
    "Edit #{etc}/rundeck.conf to configure Rundeck Server"
  end
  test do
    if File.file?("/usr/local/bin/shellcheck")
      system "/usr/local/bin/shellcheck", (bin/"rundeck-server")
      raise $CHILD_STATUS if $CHILD_STATUS > 0
    end
    system "bash", "-n", (bin/"rundeck-server")
    raise $CHILD_STATUS if $CHILD_STATUS > 0
  end
end
