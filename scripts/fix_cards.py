"""
One-shot migration of assets/data/card.json:
  A. typo / mistranslation fixes
  B. plural / compound-word fixes
  C. resolve duplicate cards (delete or rename)
  D. capitalize Indonesian and English names
  E. add 5 missing cards (assets already on disk)

Run from repo root:  python scripts/fix_cards.py
"""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CARDS = ROOT / "assets" / "data" / "card.json"


def main() -> int:
    with open(CARDS, "r", encoding="utf-8") as f:
        data = json.load(f)

    cards = data["cards"]
    by_id = {c["id"]: c for c in cards}

    def update(cid, **changes):
        card = by_id[cid]
        for k, v in changes.items():
            card[k] = v

    # ------------------------------ A. hard bugs ------------------------------
    update("c284", enName="Sad")                       # Sedih -> Sad (was Angry)
    update("c270", enName="Rectangle")                 # Ractangle
    update("c197", enName="Sweeping")                  # Brooming
    update("c225", enName="Horse Riding")              # Hourse Riding
    update("c211", enName="Stirring")                  # Stiring
    update("c127", enName="Underwear")                 # Underware
    update("c201", enName="Quiet")                     # Quite
    update("c142", name="Sunscreen", enName="Sunscreen")
    update("c104", enName="T-Shirt")                   # Tshirt
    update("c97",  enName="Backpack")                  # Bag Pack
    update("c203", enName="Fall Down")                 # Fell Down
    update("c337", enName="Many Legs")                 # Have lots of leg
    update("c321", enName="I")                         # I am
    update("c84",  name="Marakas")                     # Macara

    # ------------------------------ B. plurals --------------------------------
    update("c89",  enName="Scissors")
    update("c102", enName="Stairs")
    update("c77",  enName="Grapes")
    update("c10",  enName="Toothbrush")
    update("c11",  enName="Toothpaste")
    update("c42",  enName="Bookshelf")
    update("c54",  enName="Shoe Rack")
    update("c335", enName="Four-legged")
    update("c213", enName="Hand in the Air")
    update("c209", enName="Cross-legged")

    # ------------------------------ C. duplicates -----------------------------
    # Delete duplicates (keep the first occurrence by id):
    DELETE = {
        "c75",      # Kue / Cake (keep c70)
        "c159",     # Gantungan Baju / Hanger (keep c99)
        "c146",     # Sendal / Sandal (keep c28)
        "c347",     # 'ini' grammar (kept c279 'Ini' position)
        "c46",      # Ranjang / Bed (keep c114 Tempat Tidur)
        "c322",     # Dia 'Her' (merge into c319 below)
    }

    # Disambiguate (keep both, change enName / name):
    update("c126", enName="Liquid Soap")               # Sabun Cair
    update("c179", enName="Scissor Cutting")           # Menggunting
    update("c346", name="Adalah", enName="Is")
    update("c345", name="Sedang", enName="Currently")
    update("c319", enName="He / She")                  # Dia, gender-neutral

    # ------------------------------ D. capitalization -------------------------
    update("c266", name="Nama Mama")
    update("c267", name="Nama Papa")
    update("c262", name="Nama Nenek")
    update("c348", name="Lalu", enName="Then")

    # ------------------------------ E. add missing cards ----------------------
    existing_ids = {c["id"] for c in cards}
    next_n = max(int(c["id"][1:]) for c in cards if c["id"].startswith("c")) + 1

    def new_id() -> str:
        nonlocal next_n
        while f"c{next_n}" in existing_ids:
            next_n += 1
        cid = f"c{next_n}"
        existing_ids.add(cid)
        next_n += 1
        return cid

    new_cards = [
        {
            "name": "Alpukat",
            "enName": "Avocado",
            "categoryId": "cat2",
            "imagePath": "assets/images/img_asset/alpukat.png",
            "soundPath": "assets/sound/id/Alpukat.m4a",
            "enSoundPath": "assets/sound/en/Avocado.m4a",
        },
        {
            "name": "Susu",
            "enName": "Milk",
            "categoryId": "cat2",
            "imagePath": "assets/images/img_asset/susu.png",
            "soundPath": "assets/sound/id/susu.mp3",
            "enSoundPath": "assets/sound/en/milk.mp3",
        },
        {
            "name": "Tertawa",
            "enName": "Laugh",
            "categoryId": "cat5",
            "imagePath": "assets/images/img_asset/tertawa.png",
            "soundPath": "assets/sound/id/tertawa.mp3",
            "enSoundPath": "assets/sound/en/laugh.mp3",
        },
        {
            "name": "Cangkir",
            "enName": "Cup",
            "categoryId": "cat3",
            "imagePath": "assets/images/img_asset/cangkir.png",
            # No dedicated sound files; TTS will speak via name/enName.
            "soundPath": None,
            "enSoundPath": None,
        },
        {
            "name": "Selesai",
            "enName": "Done",
            "categoryId": "cat7",
            # No image; cat7 (adjectives) renders text-mode just fine.
            "imagePath": None,
            "soundPath": "assets/sound/id/selesai.mov",
            "enSoundPath": None,
        },
    ]

    for nc in new_cards:
        nc["id"] = new_id()
        cards.append(nc)

    # ------------------------------ apply deletions ---------------------------
    cards = [c for c in cards if c["id"] not in DELETE]
    data["cards"] = cards

    with open(CARDS, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"OK: deleted {len(DELETE)}, added {len(new_cards)}, total now {len(cards)}")
    print(f"New ids: {[c['id'] for c in new_cards]}")
    return 0


if __name__ == "__main__":
    main()
