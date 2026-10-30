# Build add-ons from the release branches of the forks and the main branch
# of the skin and commit them, see tools/release.sh for the options
# (JELLYFIN_KODI, JELLYCON, NIGHTCITY, TMDBHELPER, BRANCH, NIGHTCITY_BRANCH).

JELLYFIN_KODI ?= ../jellyfin-kodi
JELLYCON ?= ../jellycon
NIGHTCITY ?= ../kodi-skin-nightcity
TMDBHELPER ?= ../plugin.video.themoviedb.helper
export JELLYFIN_KODI JELLYCON NIGHTCITY TMDBHELPER

.PHONY: release release-jellyfin-kodi release-jellycon release-nightcity release-tmdbhelper
.PHONY: sync-master sync-master-jellyfin-kodi sync-master-jellycon

release:
	tools/release.sh jellyfin jellycon nightcity tmdbhelper

release-jellyfin-kodi:
	tools/release.sh jellyfin

release-jellycon:
	tools/release.sh jellycon

release-nightcity:
	tools/release.sh nightcity

release-tmdbhelper:
	tools/release.sh tmdbhelper

# Fast-forward master of the forks to upstream master, locally and on
# GitHub. Fails without changing anything if a master has own commits.
sync-master: sync-master-jellyfin-kodi sync-master-jellycon

sync-master-jellyfin-kodi:
	git -C $(JELLYFIN_KODI) fetch upstream master:master
	git -C $(JELLYFIN_KODI) push origin master

sync-master-jellycon:
	git -C $(JELLYCON) fetch upstream master:master
	git -C $(JELLYCON) push origin master
