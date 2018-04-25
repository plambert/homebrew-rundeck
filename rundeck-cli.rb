class RundeckCli < Formula
  desc "CLI tool for Rundeck, the Service Reliability Engineering platform"
  homepage "https://www.rundeck.com/"
  url "https://github.com/rundeck/rundeck-cli/archive/v1.0.22.tar.gz"
  sha256 "336a018ad9188a05ee5b92318408c19f32c7bd2f5d26076a2f2f612edfe5748e"
  head "https://github.com/rundeck/rundeck-cli.git", :branch => "master"
  depends_on :java => "1.8"
  def install
    system "./gradlew", "build"
    libexec.install "build/libs/rundeck-cli-#{version}-0.1.0-SNAPSHOT-all.jar"
    (bin/"rd").write <<~EOS
      #!/bin/bash
      JAVA_HOME="$(/usr/libexec/java_home -v 1.8)" exec java -jar "#{libexec}/rundeck-cli-#{version}-0.1.0-SNAPSHOT-all.jar" "$@"
    EOS
  end
  test do
    system "#{bin}/rd help | grep 'Rundeck API Client Tool'"
  end
end
