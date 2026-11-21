# Build add-ons from the release branches of the forks and the main branch
# of the skins and commit them, see tools/release.sh for the options
# (JELLYFIN_KODI, JELLYCON, NIGHTCITY, TMDBHELPER, PKC, PKC_MOVIES, PKC_TVSHOWS,
# BRANCH, NIGHTCITY_BRANCH).

JELLYFIN_KODI ?= ../jellyfin-kodi
JELLYCON ?= ../jellycon
NIGHTCITY ?= ../kodi-skin-nightcity
TMDBHELPER ?= ../plugin-video-themoviedb-helper
PKC ?= ../plexkodiconnect
PKC_MOVIES ?= ../plugin-video-plexkodiconnect-movies
PKC_TVSHOWS ?= ../plugin-video-plexkodiconnect-tvshows
export JELLYFIN_KODI JELLYCON NIGHTCITY TMDBHELPER PKC PKC_MOVIES PKC_TVSHOWS

.PHONY: release release-jellyfin-kodi release-jellycon release-nightcity release-confuse release-tmdbhelper
.PHONY: release-plexkodiconnect
.PHONY: sync-master sync-master-jellyfin-kodi sync-master-jellycon

release:
	tools/release.sh

release-jellyfin-kodi:
	tools/release.sh jellyfin

release-jellycon:
	tools/release.sh jellycon

release-nightcity:
	tools/release.sh nightcity

release-confuse:
	tools/release.sh confuse

release-tmdbhelper:
	tools/release.sh tmdbhelper

# PlexKodiConnect with its two helper add-ons (only those with a new version are released)
release-plexkodiconnect:
	tools/release.sh pkc pkcmovies pkctvshows

# Fast-forward master of the forks to upstream master, locally and on
# GitHub. Fails without changing anything if a master has own commits.
sync-master: sync-master-jellyfin-kodi sync-master-jellycon

sync-master-jellyfin-kodi:
	git -C $(JELLYFIN_KODI) fetch upstream master:master
	git -C $(JELLYFIN_KODI) push origin master

sync-master-jellycon:
	git -C $(JELLYCON) fetch upstream master:master
	git -C $(JELLYCON) push origin master
