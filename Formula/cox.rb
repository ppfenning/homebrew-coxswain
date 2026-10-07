# Coxswain's operator CLI. `cox setup doctor` tells a fresh machine what it is missing.
#
# The url and sha256 below are moved to each new PyPI sdist by the umbrella's release
# tooling (`python -m devtools release`), in a pull request opened after the publish
# succeeds.
class Cox < Formula
  include Language::Python::Virtualenv

  desc "Operator CLI for Coxswain: run records, traces, landing, and the live screens"
  homepage "https://ppfenning.github.io/coxswain/latest/"
  url "https://files.pythonhosted.org/packages/b8/1c/b6eee0e017b56636d3fd0e0c2f4360e9ee15c4720cee0d6f30293f049300/coxswain_tools-0.36.0.tar.gz"
  sha256 "db0481f8fcd0b77b82fd3a59e48a7fb508822aacd542ae7341d394cefdddaa6d"
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
        url "https://github.com/ppfenning/coxswain-dash/releases/download/v0.36.0/towpath-v0.36.0-aarch64-apple-darwin.tar.gz"
        sha256 "ddd25df78eabe36e6ca61dfe95fbba7ab20794fdf8b1cd8083ed9512bd94f70d"
      end
    end
  end

  on_linux do
    on_intel do
      resource "towpath" do
        url "https://github.com/ppfenning/coxswain-dash/releases/download/v0.36.0/towpath-v0.36.0-x86_64-unknown-linux-gnu.tar.gz"
        sha256 "f0f8876134f36a2a1aba8b93e8fda3f1301a9b202e2fdac7f61a5d8215e5d877"
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
