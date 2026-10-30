# Kodi repository by Thomas Wiebe

Kodi repository with forks of two Jellyfin add-ons and TMDb Helper, and the
Nightcity skin:

| Add-on | Id | Source |
|---|---|---|
| Jellyfin for Kodi | `plugin.video.jellyfin` | https://github.com/twiebe/jellyfin-kodi (branch `release`) |
| JellyCon | `plugin.video.jellycon` | https://github.com/twiebe/jellycon (branch `release`) |
| Nightcity | `skin.nightcity` | https://github.com/twiebe/kodi-skin-nightcity (branch `main`) |
| TMDb Helper | `plugin.video.themoviedb.helper` | https://github.com/twiebe/plugin.video.themoviedb.helper (branch `release`) |

The forks keep the add-on ids of the upstream add-ons, so settings, the
synced library, favourites and widgets keep working.

The Jellyfin add-ons require Kodi 19 or later, Nightcity Kodi 21. Nightcity
needs TMDb Helper 6.17.9 or later, which comes from this repository. TMDb
Helper in turn needs `script.module.jurialmunkey` 0.2.35 and
`script.module.infotagger` 0.1.0, which the official Kodi repository only has
in older versions: install jurialmunkey's repository first
(`repository.jurialmunkey-<version>.zip` from
`https://jurialmunkey.github.io/repository.jurialmunkey/`, added as a source
like below), then Kodi installs them together with TMDb Helper. Its other
dependencies come from the official repository or with Kodi itself.

## Why forks

The forks carry a number of fixes that upstream does not have yet. They
were written with AI assistance, which Jellyfin's contribution policy
restricts, so only part of them can go upstream and this will take a while.
The TMDb Helper fork keeps its SQLite cache from using up the address space
of a 32-bit Kodi (CoreELEC), where videos then fail to start; it goes
upstream through an issue first, as TMDb Helper's AI usage policy asks.

The forks are therefore used daily and actively maintained for the long term:
they follow upstream releases, and the fixes are reapplied on top of each one.

## Versions

`1:<upstream version>-<fork revision>`, for example `1:2.2.0-1+py3`:

- the upstream version the fork is based on,
- the fork revision, counting the fork releases on top of that upstream
  version and starting at 1 again on a new upstream version,
- the epoch `1:`, which Kodi compares first, so the fork stays ahead of
  every upstream release.

## Install

1. Settings > File manager > Add source: `https://twiebe.github.io/kodi-repo/`
2. Add-ons > Install from zip file > that source > `repository.twiebe-<version>.zip`
3. Add-ons > Install from repository > twiebe Repository > Video add-ons >
   Jellyfin, JellyCon or TMDb Helper > Install, or Look and feel > Skin >
   Nightcity > Install

If the upstream add-on is installed, Kodi asks whether to replace it, answer
Yes. When it then asks whether to remove the add-on's data, answer **No**,
otherwise the settings and the login are lost.

Kodi updates an add-on only from the repository it was installed from, so
after this step updates come from this repository. The Jellyfin repository
can stay installed.

## Upstream

`make sync-master` fast-forwards `master` of both forks to upstream master,
locally and on GitHub (`make sync-master-jellyfin-kodi`,
`make sync-master-jellycon` for one). The `release` branches stay as they
are: merging upstream into them is a release of its own, with a new version.

## Release

1. Raise the version in `release.yaml` on the `release` branch of a
   Jellyfin fork, in `addon.xml` on the `release` branch of TMDb Helper or in
   `addon.xml` on the `main` branch of the skin, and push the branch.
2. Run `make release` (all), `make release-jellyfin-kodi`,
   `make release-jellycon`, `make release-nightcity` or
   `make release-tmdbhelper`, which call

       tools/release.sh [jellyfin] [jellycon] [nightcity] [tmdbhelper]

   It builds the add-ons from the `release` branches of the forks and the
   `main` branch of the skin, which it expects next to this repository
   (override with `JELLYFIN_KODI=<path>`, `JELLYCON=<path>`,
   `NIGHTCITY=<path>` and `TMDBHELPER=<path>`), and commits the result.
   TMDb Helper has no build script: its zip is the branch as it is, without
   the GitHub and contributor files and `icon.xcf`. Needs git, tar and
   Docker, the Python part runs in a container.
3. Check the commit and push, GitHub Pages serves the result.

Under the hood `tools/build_repo.py` copies the zips to `zips/<id>/`,
writes `zips/addons.xml` with its checksum and a sha256 file for every zip,
and zips the repository add-on from `repository.twiebe/`. A version that is
already published is skipped: Kodi only updates to a higher version, so
every change needs a new one. The same goes for the repository add-on, raise
its version in `repository.twiebe/addon.xml` when changing it.
