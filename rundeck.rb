# WARNING: THIS IS A DEVELOPMENT-ONLY VERSION OF THIS FORMULA

class Rundeck < Formula
  desc "Enable self-service access to existing scripts and tools."
  homepage "http://rundeck.org"
  url "https://github.com/rundeck/rundeck/archive/v2.10.6.tar.gz"
  sha256 "b6dde4ae74ad00a3c2fac3b05f894cf3e2d9e7e8e27a118e64d15813619f4458"
  depends_on :java => "1.8"
  def install
    if Pathname.new("#{ENV["HOME"]}/.cache/rundeck-server-homebrew-cache/rundeck.build.tgz").file?
      system "tar", "-xzpf", "#{ENV["HOME"]}/.cache/rundeck-server-homebrew-cache/rundeck.build.tgz"
    else
      system "make", "app"
      if Pathname.new("#{ENV["HOME"]}/.cache/rundeck-server-homebrew-cache").directory?
        system "tar", "-czvf", "#{ENV["HOME"]}/.cache/rundeck-server-homebrew-cache/rundeck.build.tgz"
      end
    end
  end
  test do
  end
end
