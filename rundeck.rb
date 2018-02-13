# WARNING: THIS IS A DEVELOPMENT-ONLY VERSION OF THIS FORMULA, IT DOES NOT WORK!

class Rundeck < Formula
  desc "Enable self-service access to existing scripts and tools."
  homepage "http://rundeck.org"
  url "https://github.com/rundeck/rundeck/archive/v2.10.6.tar.gz"
  sha256 "b6dde4ae74ad00a3c2fac3b05f894cf3e2d9e7e8e27a118e64d15813619f4458"
  depends_on :java => "1.8"
  def install
    if File.file?("#{ENV["HOME"]}/.cache/rundeck-server-homebrew-cache/rundeck.build.tgz")
      puts "Using cached build for formula development"
      system "tar", "-xzpf", "#{ENV["HOME"]}/.cache/rundeck-server-homebrew-cache/rundeck.build.tgz"
    else
      system "make", "app"
      if File.directory?("#{ENV["HOME"]}/.cache/rundeck-server-homebrew-cache")
        puts "Creating cached build for future formula development"
        system "tar", "-czvf", "#{ENV["HOME"]}/.cache/rundeck-server-homebrew-cache/rundeck.build.tgz"
      end
    end
  end
  test do
    true
  end
end
