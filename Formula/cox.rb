# Coxswain's operator CLI. `cox setup doctor` tells a fresh machine what it is missing.
#
# The url and sha256 below are filled by `cox dev release` after the PyPI publish
# succeeds; until 0.2.0 is published this formula does not install. The sha256 is
# deliberately the empty-string digest rather than a plausible-looking constant, so
# a premature `brew install` fails loudly on the checksum instead of fetching
# something nobody verified.
class Cox < Formula
  include Language::Python::Virtualenv

  desc "Operator CLI for Coxswain: run records, traces, landing, and the live screens"
  homepage "https://ppfenning.github.io/coxswain/latest/"
  url "https://files.pythonhosted.org/packages/17/76/6b448d15d1abc62a88ad46a1e82e657cea004ce0248b4158a0c5570d8807/coxswain_tools-0.13.0.tar.gz"
  sha256 "66352a654b4f9c068656a7e5b2597d253e3d91c8d60e62f1e6a3b695097bb88d"
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
