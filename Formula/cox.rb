# Coxswain's operator CLI. `cox setup doctor` tells a fresh machine what it is missing.
#
# The url and sha256 below are moved to each new PyPI sdist by the umbrella's release
# tooling (`python -m devtools release`), in a pull request opened after the publish
# succeeds.
class Cox < Formula
  include Language::Python::Virtualenv

  desc "Operator CLI for Coxswain: run records, traces, landing, and the live screens"
  homepage "https://ppfenning.github.io/coxswain/latest/"
  url "https://files.pythonhosted.org/packages/e7/61/a38421254d6342dbef8591f2e612e1301d3f233a1b582f0826ebd0ceb4e3/coxswain_tools-0.40.0.tar.gz"
  sha256 "fac8c90900ee34ac2dd3c771f187fc39659eaaf2fd959ac2a5733c9ba12d67d6"
  license "MIT"
  head "https://github.com/ppfenning/coxswain-tools.git", branch: "main"

  depends_on "python@3.14"

  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz"
    sha256 "d76623373421df22fb4cf8817020cbb7ef15c725b9d5e45f17e189bfc384190f"
  end

  resource "zstandard" do
    url "https://files.pythonhosted.org/packages/fd/aa/3e0508d5a5dd96529cdc5a97011299056e14c6505b678fd58938792794b1/zstandard-0.25.0.tar.gz"
    sha256 "7713e1179d162cf5c7906da876ec2ccb9c3a9dcbdffef0cc7f70c3667a205f0b"
  end

  on_macos do
    on_arm do
      resource "towpath" do
        url "https://github.com/ppfenning/coxswain-dash/releases/download/v0.40.0/towpath-v0.40.0-aarch64-apple-darwin.tar.gz"
        sha256 "1cba9a42a27ca503bfd4eb149a8d5485391a92e75701a5e0157b4d5fe5a91357"
      end
    end
  end

  on_linux do
    on_intel do
      resource "towpath" do
        url "https://github.com/ppfenning/coxswain-dash/releases/download/v0.40.0/towpath-v0.40.0-x86_64-unknown-linux-gnu.tar.gz"
        sha256 "e249d87a91e43a41f17371ea242c7cc488fe557833955216d15d0c495ccac70e"
      end
    end
  end

  def install
    if resources.map(&:name).include?("towpath")
      resource("towpath").stage do
        bin.install "towpath", "coxtop"
      end
    end
    virtualenv_install_with_resources without: resources.map(&:name) & ["towpath"]
  end

  def caveats
    <<~EOS
      `cox` alone is the CLI. The rest of a Coxswain install — cartridges, graphs,
      crew, the HUD — are git checkouts this command fetches:

        cox setup doctor    # what this machine is missing
        cox install         # every component from the manifest, at the pinned tags

    EOS
  end

  test do
    system bin/"towpath", "--version" if (bin/"towpath").exist?
    assert_match "cox", shell_output("#{bin}/cox --help")
    system bin/"cox", "setup", "doctor"
  end
end
