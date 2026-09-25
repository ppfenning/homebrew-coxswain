# homebrew-coxswain

The Homebrew tap for [Coxswain](https://ppfenning.github.io/coxswain/latest/) — the
`cox` command on macOS.

```sh
brew tap ppfenning/coxswain
brew trust ppfenning/coxswain   # once: current Homebrew refuses untrusted third-party taps
brew install cox
cox setup doctor
```

## Status

Installable. The formula tracks the latest `coxswain-tools` release on PyPI. After each
publish, the umbrella's release tooling (`python -m devtools release`, run from the
coxswain checkout) opens a pull request here that moves the formula's `url` and
`sha256` to the new sdist.

On any platform, without Homebrew:

```sh
uv tool install coxswain-tools
```

## What this installs

`cox` alone. The other components — cartridges, graphs, crew, the HUD — are git
checkouts that `cox install` fetches from the umbrella's `manifest.toml`, pinned in
lockstep at the same version. One formula, one command, the rest from the manifest.
