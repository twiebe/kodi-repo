# twiebe Kodi repository

Kodi repository with forks of two Jellyfin add-ons:

| Add-on | Id | Source |
|---|---|---|
| Jellyfin for Kodi | `plugin.video.jellyfin` | https://github.com/twiebe/jellyfin-kodi (branch `release`) |
| JellyCon | `plugin.video.jellycon` | https://github.com/twiebe/jellycon (branch `release`) |

The forks keep the add-on ids of the upstream add-ons, so settings, the
synced library, favourites and widgets keep working.

Requires Kodi 19 or later.

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
   Jellyfin or JellyCon > Install

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

1. Raise the version in `release.yaml` on the `release` branch of the fork
   and push the branch.
2. Run `make release` (both), `make release-jellyfin-kodi` or
   `make release-jellycon`, which call

       tools/release.sh [jellyfin] [jellycon]

   It builds the add-ons from the `release` branches of the forks, which it
   expects next to this repository (override with `JELLYFIN_KODI=<path>`
   and `JELLYCON=<path>`), and commits the result. Needs git, tar and
   Docker, the Python part runs in a container.
3. Check the commit and push, GitHub Pages serves the result.

Under the hood `tools/build_repo.py` copies the zips to `zips/<id>/`,
writes `zips/addons.xml` with its checksum and a sha256 file for every zip,
and zips the repository add-on from `repository.twiebe/`. A version that is
already published is skipped: Kodi only updates to a higher version, so
every change needs a new one. The same goes for the repository add-on, raise
its version in `repository.twiebe/addon.xml` when changing it.
