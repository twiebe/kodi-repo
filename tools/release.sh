#!/bin/sh
# Build the add-ons from the release branch of their forks and the skin from
# its main branch, add them to the repository, then commit and tag each
# released add-on in its source repository (annotated, with what changed).
# Pushing the commit and the tags is left to you.
#
#   tools/release.sh [jellyfin] [jellycon] [nightcity]     (default: all)
#
# The sources are expected next to this repository, override with
# JELLYFIN_KODI=/path, JELLYCON=/path and NIGHTCITY=/path. BRANCH picks
# another branch of the forks, NIGHTCITY_BRANCH another one of the skin.
# Needs git, tar and Docker; the Python part runs in a container.
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
JELLYFIN_KODI=${JELLYFIN_KODI:-$ROOT/../jellyfin-kodi}
JELLYCON=${JELLYCON:-$ROOT/../jellycon}
NIGHTCITY=${NIGHTCITY:-$ROOT/../kodi-skin-nightcity}
BRANCH=${BRANCH:-release}
NIGHTCITY_BRANCH=${NIGHTCITY_BRANCH:-main}
IMAGE=kodi-repo-build
# Not .build or venv: the build.py of the add-ons skip folders with these names
BUILD=$ROOT/_release

[ $# -gt 0 ] || set -- jellyfin jellycon nightcity

if [ -n "$(git -C "$ROOT" status --porcelain)" ]; then
    echo "kodi-repo has uncommitted changes, commit or stash them first" >&2
    exit 1
fi

rm -rf "$BUILD"
mkdir -p "$BUILD/out"

for name in "$@"; do
    case $name in
        jellyfin) source=$JELLYFIN_KODI branch=$BRANCH ;;
        jellycon) source=$JELLYCON branch=$BRANCH ;;
        nightcity) source=$NIGHTCITY branch=$NIGHTCITY_BRANCH ;;
        *) echo "unknown add-on: $name (jellyfin, jellycon or nightcity)" >&2; exit 1 ;;
    esac
    commit=$(git -C "$source" rev-parse --verify --quiet "$branch^{commit}") || {
        echo "$source: no branch $branch" >&2
        exit 1
    }
    # The README links the source, so the release should be on GitHub too
    if [ "$(git -C "$source" rev-parse --verify --quiet "origin/$branch" || true)" != "$commit" ]; then
        echo "warning: $name $branch differs from origin/$branch (as of the last fetch), push it" >&2
    fi
    echo "$name: $branch at $(git -C "$source" log -1 --format='%h %s' "$commit")"
    echo "$name $source $commit" >>"$BUILD/sources"
    mkdir "$BUILD/$name"
    git -C "$source" archive "$commit" | tar -x -C "$BUILD/$name"
done

docker build -q -t "$IMAGE" "$ROOT/tools" >/dev/null
docker run --rm --user "$(id -u):$(id -g)" -v "$ROOT:/repo" -w /repo "$IMAGE" sh -ec '
    for dir in _release/*/; do
        [ "$dir" = _release/out/ ] && continue
        if [ -f "$dir/build.py" ]; then
            python "$dir/build.py" --version py3 --source "$dir" --target _release/out >/dev/null
        else
            # the skin: tools/build.py OUT_DIR
            python "$dir/tools/build.py" _release/out >/dev/null
        fi
    done
    python tools/build_repo.py _release/out/*.zip >_release/result.txt || status=$?
    cat _release/result.txt
    exit "${status:-0}"
'

added=$(sed -n 's/^added //p' "$BUILD/result.txt")
sources=$(cat "$BUILD/sources")
rm -rf "$BUILD"
if [ -z "$added" ]; then
    echo "Nothing to release: raise the version first (release.yaml of a fork, addon.xml of the skin)."
    exit 0
fi

git -C "$ROOT" add -A
git -C "$ROOT" commit -q -m "Release $(echo "$added" | paste -sd ',' - | sed 's/,/, /g')"
git -C "$ROOT" log -1 --format='Committed %h: %s'

# What changed in a release, one "- " line each: the skin's news of the version (addon.xml,
# one line per sentence); for a fork the changelog lines of release.yaml that its previous
# release tag did not have yet (all of them for the first)
notes() { # name source commit
    if [ "$1" = nightcity ]; then
        git -C "$2" show "$3:addon.xml" | tr '\n' ' ' | sed -n 's/.*<news>\([^[<]*\).*/\1/p' |
            sed 's/^ *[0-9][0-9.]* - //; s/\. /.\n/g' | sed 's/^ *//; /^$/d; s/^/- /'
    else
        before=$(git -C "$2" describe --tags --match 'v*-*' --abbrev=0 "$3^" 2>/dev/null || true)
        git -C "$2" show "$3:release.yaml" | sed -n 's/^  + //p' | while read -r line; do
            if [ -z "$before" ] || ! git -C "$2" show "$before:release.yaml" | grep -qxF "  + $line"; then
                echo "- $line"
            fi
        done
    fi
}

# Tag every released add-on in its source repository at the commit it was built from, annotated
# with what changed: v<version>, without the epoch and the +py3 of the forks (1:1.0.2-5+py3 ->
# v1.0.2-5), so a fork's tag never takes the name of an upstream one (v1.0.2)
echo "$added" | while read -r id version; do
    case $id in
        plugin.video.jellyfin) name=jellyfin ;;
        plugin.video.jellycon) name=jellycon ;;
        skin.nightcity) name=nightcity ;;
        *) continue ;;
    esac
    set -- $(echo "$sources" | grep "^$name ")
    source=$2 commit=$3
    tag=v$(echo "$version" | sed 's/^[0-9]*://; s/+py3$//')
    if git -C "$source" rev-parse --verify --quiet "refs/tags/$tag" >/dev/null; then
        echo "warning: $source already has tag $tag, left as it is" >&2
        continue
    fi
    # tagged by whoever made the release commit
    git -C "$source" -c user.name="$(git -C "$ROOT" log -1 --format=%cn)" -c user.email="$(git -C "$ROOT" log -1 --format=%ce)" \
        tag -a "$tag" -F - "$commit" <<EOF
Release $id $version

$(notes "$name" "$source" "$commit")
EOF
    echo "Tagged $name $tag at $(git -C "$source" rev-parse --short "$commit"): git -C $source push origin $tag"
done
echo "Check with git show --stat, then git push (and push the tags above)."
