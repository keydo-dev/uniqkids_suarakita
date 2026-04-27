"""
One-shot audit of assets/data/card.json:
  - duplicate ids
  - duplicate (name, categoryId) pairs (semantic dupes within a category)
  - duplicate enName within same categoryId
  - duplicate imagePath
  - missing required fields
  - missing image / sound files on disk

Run from repo root:  python scripts/audit_cards.py
"""

import json
import os
import sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CARDS = ROOT / "assets" / "data" / "card.json"
CATS = ROOT / "assets" / "data" / "categories.json"


def load(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def main() -> int:
    cards = load(CARDS)["cards"]
    cats = load(CATS)
    cat_ids = {c["id"] for c in cats} if isinstance(cats, list) else {
        c["id"] for c in cats.get("categories", [])
    }

    print(f"Loaded {len(cards)} cards, {len(cat_ids)} categories")
    print("=" * 60)

    # ------- duplicate ids -------
    id_counts = Counter(c["id"] for c in cards)
    dup_ids = [(i, n) for i, n in id_counts.items() if n > 1]
    print(f"\n[1] Duplicate ids: {len(dup_ids)}")
    for i, n in dup_ids:
        print(f"   {i!r} appears {n} times")

    # ------- duplicate (name, categoryId) -------
    by_name_cat = Counter((c["name"].strip().lower(), c["categoryId"]) for c in cards)
    dup_name = [(k, n) for k, n in by_name_cat.items() if n > 1]
    print(f"\n[2] Duplicate (name, categoryId): {len(dup_name)}")
    for (name, cat), n in dup_name:
        ids = [c["id"] for c in cards if c["name"].strip().lower() == name and c["categoryId"] == cat]
        print(f"   '{name}' in {cat} -> {n} times (ids={ids})")

    # ------- duplicate (enName, categoryId) -------
    by_en_cat = Counter(
        ((c.get("enName") or "").strip().lower(), c["categoryId"]) for c in cards
    )
    dup_en = [(k, n) for k, n in by_en_cat.items() if n > 1 and k[0]]
    print(f"\n[3] Duplicate (enName, categoryId): {len(dup_en)}")
    for (en, cat), n in dup_en:
        ids = [c["id"] for c in cards if (c.get("enName") or "").strip().lower() == en and c["categoryId"] == cat]
        print(f"   '{en}' in {cat} -> {n} times (ids={ids})")

    # ------- duplicate imagePath (same image used across cards) -------
    image_users = defaultdict(list)
    for c in cards:
        ip = (c.get("imagePath") or "").strip()
        if ip:
            image_users[ip].append((c["id"], c["name"], c["categoryId"]))
    dup_img = {ip: users for ip, users in image_users.items() if len(users) > 1}
    print(f"\n[4] Duplicate imagePath (same image, multiple cards): {len(dup_img)}")
    for ip, users in dup_img.items():
        print(f"   {ip}")
        for cid, n, cat in users:
            print(f"      {cid:6} {n:30} {cat}")

    # ------- missing fields -------
    REQUIRED = ["id", "name", "categoryId"]
    OPTIONAL = ["enName", "imagePath", "soundPath", "enSoundPath"]
    missing_req = []
    missing_opt = defaultdict(list)
    for c in cards:
        for f in REQUIRED:
            if not c.get(f):
                missing_req.append((c.get("id", "?"), f))
        for f in OPTIONAL:
            v = c.get(f)
            if v is None or (isinstance(v, str) and not v.strip()):
                missing_opt[f].append((c["id"], c.get("name", "")))

    print(f"\n[5] Cards missing REQUIRED field: {len(missing_req)}")
    for cid, f in missing_req:
        print(f"   {cid} missing {f}")
    print(f"\n[6] Cards with missing optional field counts:")
    for f, lst in missing_opt.items():
        print(f"   {f:14}: {len(lst)} cards")

    # ------- orphan categoryId -------
    bad_cat = [c for c in cards if c["categoryId"] not in cat_ids]
    print(f"\n[7] Cards with unknown categoryId: {len(bad_cat)}")
    for c in bad_cat[:25]:
        print(f"   {c['id']:6} {c['name']:25} -> {c['categoryId']}")
    if len(bad_cat) > 25:
        print(f"   ... and {len(bad_cat)-25} more")

    # ------- referenced files that don't exist -------
    print(f"\n[8] Missing files on disk:")
    counts = {"imagePath": 0, "soundPath": 0, "enSoundPath": 0}
    examples = {"imagePath": [], "soundPath": [], "enSoundPath": []}
    for c in cards:
        for field in ["imagePath", "soundPath", "enSoundPath"]:
            p = c.get(field)
            if not p:
                continue
            full = ROOT / p
            if not full.exists():
                counts[field] += 1
                if len(examples[field]) < 8:
                    examples[field].append((c["id"], p))
    for field, n in counts.items():
        print(f"   {field:14}: {n} missing")
        for cid, p in examples[field]:
            print(f"      {cid}  {p}")

    # ------- unused asset files (orphans on disk not referenced) -------
    print(f"\n[9] Orphan asset files (on disk but not referenced):")
    used_imgs = {c.get("imagePath") for c in cards if c.get("imagePath")}
    used_snds = {c.get("soundPath") for c in cards if c.get("soundPath")} | {
        c.get("enSoundPath") for c in cards if c.get("enSoundPath")
    }
    img_dir = ROOT / "assets" / "images" / "img_asset"
    if img_dir.is_dir():
        on_disk = {f"assets/images/img_asset/{f.name}" for f in img_dir.iterdir() if f.is_file()}
        orphans = sorted(on_disk - used_imgs)
        print(f"   image orphans: {len(orphans)}")
        for o in orphans[:15]:
            print(f"      {o}")
        if len(orphans) > 15:
            print(f"      ... and {len(orphans)-15} more")
    for lang in ("id", "en"):
        sd = ROOT / "assets" / "sound" / lang
        if sd.is_dir():
            on_disk = {f"assets/sound/{lang}/{f.name}" for f in sd.iterdir() if f.is_file()}
            orphans = sorted(on_disk - used_snds)
            print(f"   sound/{lang} orphans: {len(orphans)}")
            for o in orphans[:15]:
                print(f"      {o}")
            if len(orphans) > 15:
                print(f"      ... and {len(orphans)-15} more")

    return 0


if __name__ == "__main__":
    sys.exit(main())
