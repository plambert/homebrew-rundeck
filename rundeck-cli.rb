class RundeckCli < Formula
  desc "CLI tool for Rundeck, the Service Reliability Engineering platform"
  homepage "https://www.rundeck.com/"
  url "https://github.com/rundeck/rundeck-cli/archive/v1.1.0.tar.gz"
  sha256 "bd86a71e2934b68357acd0a688439a99cb9eb00aeb13c143b595d1f9f6b068e3"
  bottle do
    root_url "https://plambert.net/rundeck"
    cellar :any_skip_relocation
    sha256 "7c5199a17738bfa107dd205d439d49e1dc0ba47ace10b9ac2ea0e735f0cf810e" => :high_sierra
  end
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
