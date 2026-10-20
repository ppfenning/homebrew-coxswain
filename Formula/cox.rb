# Coxswain's operator CLI. `cox setup doctor` tells a fresh machine what it is missing.
#
# The url and sha256 below are moved to each new PyPI sdist by the umbrella's release
# tooling (`python -m devtools release`), in a pull request opened after the publish
# succeeds.
class Cox < Formula
  include Language::Python::Virtualenv

  desc "Operator CLI for Coxswain: run records, traces, landing, and the live screens"
  homepage "https://ppfenning.github.io/coxswain/latest/"
  url "https://files.pythonhosted.org/packages/78/d1/52aa6df639616692209e66096be3965721ba1b8a889dddfb939000bf0508/coxswain-2026.10.1.tar.gz"
  sha256 "da80d616a1529e78da2127a00b2271ea61b7d9661cb0e54e8a955325dd25c6a8"
  license "MIT"
  head "https://github.com/ppfenning/coxswain.git", branch: "main"

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
        url "https://github.com/ppfenning/coxswain-dash/releases/download/v2026.10.1/towpath-v2026.10.1-aarch64-apple-darwin.tar.gz"
        sha256 "c925dbc18cdcb8d1bcae0402db17dc7fd29893a615995ab2e3bb99c1c64c0ded"
      end
    end
  end

  on_linux do
    on_intel do
      resource "towpath" do
        url "https://github.com/ppfenning/coxswain-dash/releases/download/v2026.10.1/towpath-v2026.10.1-x86_64-unknown-linux-gnu.tar.gz"
        sha256 "4d3b1c07c27eac8dbc9f8adf472463f67702ccd277729fa94d7dcfc9ec05d166"
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
      `cox` alone is the CLI. The rest of a Coxswain install is one checkout of the
      coxswain repository (and coxswain-dash with `--with dash`), which this command fetches:

        cox setup doctor    # what this machine is missing
        cox install         # the coxswain checkout at this release

      Coming from 0.47? Run `cox setup migrate`, then `cox setup migrate --apply`.
    EOS
  end

  test do
    system bin/"towpath", "--version" if (bin/"towpath").exist?
    assert_match "cox", shell_output("#{bin}/cox --help")
    system bin/"cox", "setup", "doctor"
  end
end
