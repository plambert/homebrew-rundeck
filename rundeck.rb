# WARNING: THIS IS A DEVELOPMENT-ONLY VERSION OF THIS FORMULA, IT DOES NOT WORK!

class Rundeck < Formula
  desc "Enable self-service access to existing scripts and tools."
  homepage "http://rundeck.org"
  # for testing, do a 'brew install rundeck -i' and run 'make app && tar -czf ~/rundeck.build.tgz --exclude .brew* .'
  # then uncomment this url and comment the real versions, as well as the 'system make app'
  # you might want to remove any unneeded files between the 'make app' and 'tar' commands in order to
  # reduce the size of the rundeck.build.tgz file considerably.
  # url "file://#{ENV['HOME']}/rundeck.build.tgz"

  # comment these two lines when testing
  url "https://github.com/rundeck/rundeck/archive/v2.10.6.tar.gz"
  sha256 "b6dde4ae74ad00a3c2fac3b05f894cf3e2d9e7e8e27a118e64d15813619f4458"
  version "2.10.6"
  depends_on :java => "1.8"
  def install
    # comment this line when testing
    system "make", "app"
    libexec.install "rundeck-launcher/launcher/build/libs/rundeck-launcher-#{version}.jar"
    (bin/"rundeck-server").write <<~EOS
      #!/usr/bin/env bash
      JAVA_HOME="$(/usr/libexec/java_home -v 1.8)" exec java -jar "#{libexec}/rundeck-launcher-#{version}.jar" "$@"
    EOS
  end
  test do
    true
  end
end
