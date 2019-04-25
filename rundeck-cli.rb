class RundeckCli < Formula
  desc "CLI tool for Rundeck, the Service Reliability Engineering platform"
  homepage "https://www.rundeck.com/"
  url "https://github.com/rundeck/rundeck-cli/archive/v1.1.2.tar.gz"
  sha256 "030837ef6b06fa27a5d1a8e39c78ecd98d64ccd496d81fb195e2d419c19cf911"
  bottle do
    root_url "https://plambert.net/rundeck"
    cellar :any_skip_relocation
    sha256 "90635fa0d9e9b5fc746ca18d9046cc134d3cde8f7a8ca5d1c7461b445af0e9ce" => :mojave
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
