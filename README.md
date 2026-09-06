# homebrew-coxswain

The Homebrew tap for [Coxswain](https://ppfenning.github.io/coxswain/latest/) — the
`cox` command on macOS.

```sh
brew install ppfenning/coxswain/cox
cox setup doctor
```

## Status

**Not installable yet.** The formula targets `0.2.0`, which is not published. Its
`sha256` is a zero digest on purpose: a premature install fails on the checksum
rather than fetching something unverified. Two lines change when 0.2.0 ships — the
`url` and the `sha256` — and `cox dev release` fills them after the PyPI publish.

Until then, on any platform:

```sh
uv tool install coxswain-tools
```

## What this installs

`cox` alone. The other components — cartridges, graphs, crew, the HUD — are git
checkouts that `cox install` fetches from the umbrella's `manifest.toml`, pinned in
lockstep at the same version. One formula, one command, the rest from the manifest.
