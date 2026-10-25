#!/usr/bin/env python3
"""Build the Kodi repository from add-on zips.

    tools/build_repo.py [ADDON_ZIP ...]

Each zip is copied to zips/<id>/<id>-<version>.zip together with the assets
its addon.xml names, and its addon.xml is added to zips/addons.xml. The
repository add-on is zipped from repository.twiebe/ and added as well, so it
can update itself. Zips already in zips/ stay in the index, older versions
of the same add-on are removed. A version that is already published is
skipped, so every change needs a new version.

Versions can carry a Kodi epoch ("1:2.2.0-1+py3"). File names leave the
epoch out and replace "+" with "-", the <path> element in addons.xml points
Kodi (19 and later) to the file.
"""

import hashlib
import io
import shutil
import sys
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ZIPS = ROOT / "zips"
REPO_ADDON = "repository.twiebe"


def file_version(version):
    return version.split(":", 1)[-1].replace("+", "-")


def read_addon_xml(archive):
    names = [n for n in archive.namelist() if n.count("/") == 1 and n.endswith("/addon.xml")]
    if len(names) != 1:
        raise SystemExit("%s: no single <id>/addon.xml" % archive.filename)
    return ET.fromstring(archive.read(names[0]))


def assets(addon):
    """Paths of the icon, fanart, screenshots etc. named in addon.xml."""
    found = []
    for meta in addon.iter("extension"):
        if meta.get("point") not in ("xbmc.addon.metadata", "kodi.addon.metadata"):
            continue
        for element in meta.findall("assets/*"):
            if element.text and element.text.strip():
                found.append(element.text.strip())
    return found


def add_zip(source):
    """Add an add-on zip, return False if its version is already published.

    Devices only update to a higher version, so a changed add-on with the
    same version would never reach them.
    """
    with zipfile.ZipFile(source) as archive:
        addon = read_addon_xml(archive)
        addon_id, version = addon.get("id"), addon.get("version")
        target_dir = ZIPS / addon_id
        target = target_dir / ("%s-%s.zip" % (addon_id, file_version(version)))
        if target.exists():
            print("%s %s is already published, skipped" % (addon_id, version))
            return False
        if target_dir.exists():
            shutil.rmtree(target_dir)
        target_dir.mkdir(parents=True)
        for asset in assets(addon):
            data = archive.read("%s/%s" % (addon_id, asset))
            (target_dir / asset).parent.mkdir(parents=True, exist_ok=True)
            (target_dir / asset).write_bytes(data)
    shutil.copyfile(source, target)
    print("added %s %s" % (addon_id, version))
    return True


def zip_repo_addon():
    """Zip the repository add-on, return the zip if it is new or changed."""
    source = ROOT / REPO_ADDON
    files = {
        "%s/%s" % (REPO_ADDON, path.relative_to(source).as_posix()): path.read_bytes()
        for path in sorted(source.rglob("*"))
        if path.is_file()
    }
    version = ET.fromstring(files["%s/addon.xml" % REPO_ADDON]).get("version")
    built = ROOT / ("%s-%s.zip" % (REPO_ADDON, file_version(version)))
    if built.exists():
        with zipfile.ZipFile(built) as archive:
            published = {name: archive.read(name) for name in archive.namelist()}
        if published == files:
            return None
        raise SystemExit(
            "%s/ changed, raise its version %s in addon.xml" % (REPO_ADDON, version)
        )
    data = io.BytesIO()
    with zipfile.ZipFile(data, "w", zipfile.ZIP_DEFLATED) as archive:
        for name, content in files.items():
            archive.writestr(name, content)
    for old in ROOT.glob("%s-*.zip" % REPO_ADDON):
        old.unlink()
    built.write_bytes(data.getvalue())
    return built


def write_index():
    index = ET.Element("addons")
    for target in sorted(ZIPS.glob("*/*.zip")):
        with zipfile.ZipFile(target) as archive:
            addon = read_addon_xml(archive)
        for meta in addon.iter("extension"):
            if meta.get("point") in ("xbmc.addon.metadata", "kodi.addon.metadata"):
                for old in meta.findall("path"):
                    meta.remove(old)
                ET.SubElement(meta, "path").text = target.relative_to(ZIPS).as_posix()
        index.append(addon)
        digest = hashlib.sha256(target.read_bytes()).hexdigest()
        target.with_name(target.name + ".sha256").write_text(digest + "\n")
    ET.indent(index)
    xml = b'<?xml version="1.0" encoding="UTF-8"?>\n' + ET.tostring(index, encoding="utf-8") + b"\n"
    (ZIPS / "addons.xml").write_bytes(xml)
    (ZIPS / "addons.xml.md5").write_text(hashlib.md5(xml).hexdigest())


def write_html():
    # Kodi's file manager reads the links of the page to list the "directory"
    names = sorted(path.name for path in ROOT.glob("%s-*.zip" % REPO_ADDON))
    links = "".join('<a href="%s">%s</a>\n' % (name, name) for name in names)
    (ROOT / "index.html").write_text(
        "<!DOCTYPE html>\n<html><head><meta charset=\"utf-8\"><title>twiebe Kodi Repository</title></head>\n"
        "<body>\n%s</body></html>\n" % links
    )
    (ROOT / ".nojekyll").touch()


def main(sources):
    ZIPS.mkdir(exist_ok=True)
    repo_zip = zip_repo_addon()
    changed = [add_zip(repo_zip)] if repo_zip else []
    changed += [add_zip(Path(source)) for source in sources]
    if not any(changed):
        print("nothing new")
        return
    write_index()
    write_html()


if __name__ == "__main__":
    main(sys.argv[1:])
