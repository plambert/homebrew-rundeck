class RundeckCli < Formula
  desc "CLI tool for Rundeck, the Service Reliability Engineering platform"
  homepage "https://www.rundeck.com/"
  url "https://github.com/rundeck/rundeck-cli/archive/v1.0.25.tar.gz"
  sha256 "74f5f7bbea0aa2d92a50e63e399251683c3aa4d662f0ccce7de287e2f94e502b"
  bottle do
    root_url "https://plambert.net/rundeck"
    cellar :any_skip_relocation
    sha256 "6eb39d6354714737a01376059f51e9e2d4413968070e3999c37e3f5a5f13ea04" => :high_sierra
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
