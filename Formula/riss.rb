class Riss < Formula
  desc "The SAT Solving Package Riss"
  homepage "http://tools.computational-logic.org/content/riss.php"

  stable do
    url "http://tools.computational-logic.org/content/riss/Riss.tar.gz"
    version "4.27"
    sha256 "8d7955193d31155f1e2c4ffba3af68033baceaf5c4fb7272e32b1b310e3d2573"
  end

  patch do
    url "https://git.io/vrQxX"
    sha256 "2735f6704743952db6a6b5e7d8bb511e09da3fac05d565401b49323110b8b53f"
  end

  def install
    system "make"
    system "make", "coprocessorRS"
    bin.install "riss", "coprocessor"
  end

  test do
    system "riss", "--help"
  end
end
