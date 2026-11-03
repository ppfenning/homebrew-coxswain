# Coxswain's operator CLI. `cox setup doctor` tells a fresh machine what it is missing.
#
# The url and sha256 below are moved to each new PyPI sdist by the umbrella's release
# tooling (`python -m devtools release`), in a pull request opened after the publish
# succeeds.
class Cox < Formula
  include Language::Python::Virtualenv

  desc "Operator CLI for Coxswain: run records, traces, landing, and the live screens"
  homepage "https://ppfenning.github.io/coxswain/latest/"
  url "https://files.pythonhosted.org/packages/4e/62/6cf5de6abe14fbb75bcc87b70f5de75458d3496f3b93f0b60610d4fc6eb3/coxswain-2026.11.1.tar.gz"
  sha256 "838a47e191ec65e428be45428736fa0a6a773086cb76f06f15d96da2983bf9e7"
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

  resource "psycopg" do
    url "https://files.pythonhosted.org/packages/76/26/3ea4ca5eaea1c0debcdf7ee7c1613fbe721dc27a03c461c0817ffd8a0601/psycopg-3.3.6.tar.gz"
    sha256 "c081f2250df751a943036e42db6df4571c66cd0aabe8291a7a506512b12007d2"
  end

  on_macos do
    on_arm do
      resource "psycopg-binary" do
        url "https://files.pythonhosted.org/packages/63/da/28befc84454cbc6374550de7746f591f8fe1b6165c1fce249652cc8291c4/psycopg_binary-3.3.6-cp314-cp314-macosx_11_0_arm64.whl", using: :nounzip
        sha256 "5927b7ba63153cd8e9862987290a2b783a5c590daf2a4ef981700cc3569166d4"
      end
    end
  end

  on_linux do
    on_intel do
      resource "psycopg-binary" do
        url "https://files.pythonhosted.org/packages/49/6d/7692d0d4e656b6cc9868d8acc2e3b42f17a0db4a625400a6d093cb0533a1/psycopg_binary-3.3.6-cp314-cp314-manylinux2014_x86_64.manylinux_2_17_x86_64.whl", using: :nounzip
        sha256 "31cd942c23f613276b81a6e6598cefa12960058b0f46e1e874b540c793f6aca5"
      end
    end
  end

  on_macos do
    on_arm do
      resource "towpath" do
        url "https://github.com/ppfenning/coxswain-dash/releases/download/v2026.11.1/towpath-v2026.11.1-aarch64-apple-darwin.tar.gz"
        sha256 "e551b3b1d7407c97565773d3259d3a709c7a70225f3f883a98ca50ea7c687607"
      end
    end
  end

  on_linux do
    on_intel do
      resource "towpath" do
        url "https://github.com/ppfenning/coxswain-dash/releases/download/v2026.11.1/towpath-v2026.11.1-x86_64-unknown-linux-gnu.tar.gz"
        sha256 "67d0e31bcf805ebe812bea91cc705c8e0314201df677b5545073f0e2440925a2"
      end
    end
  end

  def install
    if resources.map(&:name).include?("towpath")
      resource("towpath").stage do
        bin.install "towpath", "coxtop"
      end
    end
    virtualenv_install_with_resources without: resources.map(&:name) & ["towpath", "psycopg-binary"]
    if resources.map(&:name).include?("psycopg-binary")
      resource("psycopg-binary").stage do
        system Formula["python@3.14"].opt_bin/"python3.14", "-m", "pip", "--python=#{libexec}/bin/python",
               "install", "--no-deps", "--no-index", Dir["*.whl"].first
      end
    end
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
