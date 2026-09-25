# Coxswain's operator CLI. `cox setup doctor` tells a fresh machine what it is missing.
#
# The url and sha256 below are moved to each new PyPI sdist by the umbrella's release
# tooling (`python -m devtools release`), in a pull request opened after the publish
# succeeds.
class Cox < Formula
  include Language::Python::Virtualenv

  desc "Operator CLI for Coxswain: run records, traces, landing, and the live screens"
  homepage "https://ppfenning.github.io/coxswain/latest/"
  url "https://files.pythonhosted.org/packages/b9/da/e0f7f9dd3b11fd5676f8624ae094fc61b1a85745382ff85044c2e5b6c193/coxswain_tools-0.14.0.tar.gz"
  sha256 "3a625cb622ebb7a5303d34e91ac817e7913b7558b465600183d783c448aac0de"
  license "MIT"
  head "https://github.com/ppfenning/coxswain-tools.git", branch: "main"

  depends_on "python@3.12"

  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz"
    sha256 "d76623373421df22fb4cf8817020cbb7ef15c725b9d5e45f17e189bfc384190f"
  end

  def install
    virtualenv_install_with_resources
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
    assert_match "cox", shell_output("#{bin}/cox --help")
    system bin/"cox", "setup", "doctor"
  end
end
