class Rerun < Formula
  desc "A modular shell automation framework to organize your keeper scripts."
  homepage "http://rerun.sh"
  url "https://github.com/rerun/rerun/archive/v1.4.395.tar.gz"
  sha256 "5b572cbe4ebfe3be4a19d722dbc188ac9ac6e8eceffe2be6ca7ae200faa08039"

  # depends_on "autoconf" => :build
  # depends_on "automake" => :build
  def install
    # system "autoreconf", "--install"
    # system "./configure", "--prefix=#{prefix}"
    # system "make"
    bin.install "rerun"
    Dir["modules/*"].each do |module_dir|
      STDERR.puts "+ #{module_dir}"
      (prefix/"lib"/"rerun"/"modules"/File.basename(module_dir)).install_symlink module_dir
    end
    man1.install "man/man1/rerun.1"
    ['AUTHORS', 'README', 'README.md', 'COPYING', 'NEWS'].each do |file|
      pkgshare.install file
    end
  end

  test do
    `rerun` =~ /stubbs: "Simple rerun module builder"/
  end
end
