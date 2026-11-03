# Coxswain's operator CLI. `cox setup doctor` tells a fresh machine what it is missing.
#
# The url and sha256 below are moved to each new PyPI sdist by the umbrella's release
# tooling (`python -m devtools release`), in a pull request opened after the publish
# succeeds.
class Cox < Formula
  include Language::Python::Virtualenv

  desc "Operator CLI for Coxswain: run records, traces, landing, and the live screens"
  homepage "https://ppfenning.github.io/coxswain/latest/"
  url "https://files.pythonhosted.org/packages/bd/cd/c1471efb94fa15bfb231a0889f1b0d236a02e74934e66337b1f1ee5a9a2e/coxswain-2026.11.2.tar.gz"
  sha256 "769dd95b126f10e8e3a8cdae1ce277e5312a9e3ad622e3d6dba8e823f1ed17d6"
  license "MIT"
  head "https://github.com/ppfenning/coxswain.git", branch: "main"

  depends_on "libpq"
  depends_on "python@3.14"
  depends_on "apache-arrow"
  depends_on "cmake" => :build

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
      resource "towpath" do
        url "https://github.com/ppfenning/coxswain-dash/releases/download/v2026.11.2/towpath-v2026.11.2-aarch64-apple-darwin.tar.gz"
        sha256 "901e7a5914c60f991d0205f1fb69bcb23a8265f8dfde40db27e93e44ed262fd2"
      end
    end
  end

  on_linux do
    on_intel do
      resource "towpath" do
        url "https://github.com/ppfenning/coxswain-dash/releases/download/v2026.11.2/towpath-v2026.11.2-x86_64-unknown-linux-gnu.tar.gz"
        sha256 "23fd28de4153c1475f00bf5e35476b081d04059f8cba5a38f6b32daa4c344c26"
      end
    end
  end

  resource "pyarrow" do
    url "https://files.pythonhosted.org/packages/ec/34/17c34cb38e5d940e38f0f0d9fdfa0e8a506676409ea9b85aff7e3079f831/pyarrow-26.0.0.tar.gz"
    sha256 "0cccd36e00ea3afeb52ded61f2721ce71f604853d70c45365c58324eb773d6ae"
  end

  def install
    if resources.map(&:name).include?("towpath")
      resource("towpath").stage do
        bin.install "towpath", "coxtop"
      end
    end
    # pyarrow builds from its sdist against Homebrew's apache-arrow; a wheel would bundle libraries Homebrew cannot relink.
    ENV["ARROW_HOME"] = Formula["apache-arrow"].opt_prefix
    ENV["PYARROW_CMAKE_OPTIONS"] = "-DCMAKE_PREFIX_PATH=#{Formula["apache-arrow"].opt_prefix}"
    virtualenv_install_with_resources without: resources.map(&:name) & ["towpath"]
    # psycopg is pure Python here and loads libpq through ctypes. Homebrew's libpq is keg-only,
    # so the entry points carry its lib directory on the loader's fallback path. Shipping the
    # psycopg-binary wheel instead fails: its bundled dylibs cannot be relinked by Homebrew.
    libpq_env = if OS.mac?
      { DYLD_FALLBACK_LIBRARY_PATH: Formula["libpq"].opt_lib }
    else
      { LD_LIBRARY_PATH: Formula["libpq"].opt_lib }
    end
    %w[cox agent-tools cartridge].each do |name|
      next unless (libexec/"bin"/name).exist?

      rm bin/name if (bin/name).exist? || (bin/name).symlink?
      (bin/name).write_env_script libexec/"bin"/name, libpq_env
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
    libpq_var = OS.mac? ? "DYLD_FALLBACK_LIBRARY_PATH" : "LD_LIBRARY_PATH"
    with_env(libpq_var => Formula["libpq"].opt_lib.to_s) do
      assert_match(/\d/, shell_output("#{libexec}/bin/python -c 'import psycopg; print(psycopg.pq.version())'"))
    end
    # A bucket cannot be reached inside the Homebrew test sandbox, so this asserts that the object store client is
    # importable (pyarrow), not that the bucket is reachable.
    (testpath/"provider.yaml").write("storage_url: postgresql://doctor@127.0.0.1:1/doctor\ntraces_url: s3://cox-doctor-probe/traces\nobject_store:\n  endpoint: https://127.0.0.1:9\n")
    (testpath/"profile.yaml").write("provider_profile: #{testpath}/provider.yaml\nstore:\n  mode: shared\n")
    doctor = shell_output("#{bin}/cox setup doctor --profile #{testpath}/profile.yaml 2>&1", nil)
    assert_match "object_store", doctor
    refute_match "needs a client library that is not installed", doctor
  end
end
