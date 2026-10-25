# Build add-ons from the release branches of the forks and commit them,
# see tools/release.sh for the options (JELLYFIN_KODI, JELLYCON, BRANCH).

.PHONY: release release-jellyfin-kodi release-jellycon

release:
	tools/release.sh jellyfin jellycon

release-jellyfin-kodi:
	tools/release.sh jellyfin

release-jellycon:
	tools/release.sh jellycon
