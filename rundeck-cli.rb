class RundeckCli < Formula
  desc "CLI tool for Rundeck, the Service Reliability Engineering platform"
  homepage "https://www.rundeck.com/"
  url "https://github.com/rundeck/rundeck-cli/archive/v1.0.25.tar.gz"
  sha256 "74f5f7bbea0aa2d92a50e63e399251683c3aa4d662f0ccce7de287e2f94e502b"
  bottle do
    root_url "https://rundeckpro.bintray.com/homebrew-rundeck"
    cellar :any_skip_relocation
    sha256 "1ac6140e4a170ca6daac99e7ca929aaf2f8904561a4398192d3c9e908984e41b" => :high_sierra
    rebuild 1
  end
  head "https://github.com/rundeck/rundeck-cli.git", :branch => "master"
  depends_on :java => "1.8"
  def install
    system "./gradlew", "build"
    libexec.install "build/libs/rundeck-cli-#{version}-0.1.0-SNAPSHOT-all.jar" => "rundeck-cli-#{version}.jar"
    (bin/"rd").write <<~EOS
      #!/bin/bash
      JAVA_HOME="$(/usr/libexec/java_home -v 1.8)" java -jar "#{libexec}/rundeck-cli-#{version}.jar" "$@"
    EOS
  end
  test do
    system "#{bin}/rd help | grep 'Rundeck API Client Tool'"
  end
end
