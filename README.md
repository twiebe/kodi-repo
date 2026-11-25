# Kodi repository by Thomas Wiebe

The official home of the **Nightcity** and **Confuse** skins, and of
maintained forks of great add-ons that get some additional love: tuned for
usability, performance and stability, and kept up with upstream releases.

## Skins

This repository is where Nightcity and Confuse are published. Installing them
from here gets every update as soon as it is out, together with the TMDb
Helper build they are made for.

| Skin | Id | Source |
|---|---|---|
| Nightcity | `skin.nightcity` | https://github.com/twiebe/kodi-skin-nightcity (branch `main`) |
| Confuse | `skin.confuse` | https://github.com/twiebe/kodi-skin-nightcity (branch `main`, `skins/confuse`) |

## Maintained forks

Each fork follows its upstream and adds what daily use asks for: settings
that explain themselves, faster library syncs, and fixes for the hangs,
crashes and lost data that show up on real libraries and small devices like
a CoreELEC box.

| Add-on | Id | Source |
|---|---|---|
| Jellyfin for Kodi | `plugin.video.jellyfin` | https://github.com/twiebe/jellyfin-kodi (branch `release`) |
| JellyCon | `plugin.video.jellycon` | https://github.com/twiebe/jellycon (branch `release`) |
| PlexKodiConnect | `plugin.video.plexkodiconnect` | https://github.com/twiebe/PlexKodiConnect (branch `release`) |
| PlexKodiConnect Helper Movies | `plugin.video.plexkodiconnect.movies` | https://github.com/twiebe/plugin.video.plexkodiconnect.movies (branch `release`) |
| PlexKodiConnect Helper TV Shows | `plugin.video.plexkodiconnect.tvshows` | https://github.com/twiebe/plugin.video.plexkodiconnect.tvshows (branch `release`) |
| TMDb Helper | `plugin.video.themoviedb.helper` | https://github.com/twiebe/plugin.video.themoviedb.helper (branch `release`) |

PlexKodiConnect needs its two helper add-ons, which play movies and episodes
from the Kodi library. Upstream publishes them only in its own repository, so
they are here as well, unchanged, and PlexKodiConnect installs from this
repository alone.

All of this builds on the great work of the original authors: the Jellyfin
team and contributors behind Jellyfin for Kodi and JellyCon, croneter and
the contributors of PlexKodiConnect, and jurialmunkey with TMDb Helper.
Thank you! The forks only exist because these add-ons are so good to begin
with.

The forks keep the add-on ids of the upstream add-ons, so settings, the
synced library, favourites and widgets keep working.

The Jellyfin add-ons and PlexKodiConnect require Kodi 19 or later, the skins
Kodi 21. Both skins need TMDb Helper 6.17.9 or later, which comes from this
repository. TMDb Helper in turn needs `script.module.jurialmunkey` 0.2.39 and
`script.module.infotagger` 0.1.0, which the official Kodi repository only has
in older versions: install jurialmunkey's repository first
(`repository.jurialmunkey-<version>.zip` from
`https://jurialmunkey.github.io/repository.jurialmunkey/`, added as a source
like below), then Kodi installs them together with TMDb Helper. Its other
dependencies come from the official repository or with Kodi itself.

## Why forks

The forks carry optimisations, stability improvements and bug fixes that
upstream does not have, at least not yet. They were written with AI
assistance, which the contribution policies of some upstream projects
restrict, so only part of them can go upstream, and that takes a while. A
fix that upstream solves on its own is dropped from the fork again.

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
   Jellyfin, JellyCon, PlexKodiConnect or TMDb Helper > Install, or Look and
   feel > Skin > Nightcity or Confuse > Install

If the upstream add-on is installed, Kodi asks whether to replace it, answer
Yes. When it then asks whether to remove the add-on's data, answer **No**,
otherwise the settings and the login are lost.

Kodi updates an add-on only from the repository it was installed from, so
after this step updates come from this repository. The Jellyfin repository
and PlexKodiConnect's own repository can stay installed.

## Upstream

`make sync-master` fast-forwards `master` of both forks to upstream master,
locally and on GitHub (`make sync-master-jellyfin-kodi`,
`make sync-master-jellycon` for one). The `release` branches stay as they
are: merging upstream into them is a release of its own, with a new version.

## Release

1. Raise the version in `release.yaml` on the `release` branch of a
   Jellyfin fork, in `addon.xml` on the `release` branch of TMDb Helper,
   PlexKodiConnect or its helper add-ons (with the news of the version on
   top of `<news>` and `changelog.txt`), or in `addon.xml` or
   `skins/confuse/addon.xml` on the `main` branch of the skins, and push the
   branch.
2. Run `make release` (all), `make release-jellyfin-kodi`,
   `make release-jellycon`, `make release-nightcity`, `make release-confuse`,
   `make release-tmdbhelper` or `make release-plexkodiconnect`, which call

       tools/release.sh [jellyfin] [jellycon] [nightcity] [confuse] [tmdbhelper] [pkc] [pkcmovies] [pkctvshows]

   Nightcity and Confuse are released on their own: `nightcity` builds only
   Nightcity. `make release` (all) includes Confuse once the branch of the skins
   has `skins/confuse`. Confuse has its own version and its tags are
   `confuse-v<version>`, as it shares its source repository with Nightcity.

   It builds the add-ons from the `release` branches of the forks and the
   `main` branch of the skins, which it expects next to this repository
   (override with `JELLYFIN_KODI=<path>`, `JELLYCON=<path>`,
   `NIGHTCITY=<path>`, `TMDBHELPER=<path>`, `PKC=<path>`, `PKC_MOVIES=<path>`
   and `PKC_TVSHOWS=<path>`), and commits the result. TMDb Helper,
   PlexKodiConnect and its helper add-ons have no build script: their zip is
   the branch as it is, without the GitHub and contributor files (and
   `icon.xcf`, PlexKodiConnect's tests). It tags each released add-on in its
   source repository, `v<version>` without the epoch, annotated with the news
   of the version. Needs git, tar and Docker, the Python part runs in a
   container.
3. Check the commit and push, GitHub Pages serves the result.

Under the hood `tools/build_repo.py` copies the zips to `zips/<id>/`,
writes `zips/addons.xml` with its checksum and a sha256 file for every zip,
and zips the repository add-on from `repository.twiebe/`. A version that is
already published is skipped: Kodi only updates to a higher version, so
every change needs a new one. The same goes for the repository add-on, raise
its version in `repository.twiebe/addon.xml` when changing it.
