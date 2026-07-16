from re import findall
from pathlib import Path
import json

balatroRoot = Path("C:/Program Files (x86)/Steam/steamapps/common/Balatro/Balatro")
game_path = balatroRoot.joinpath(Path("game.lua"))

def get_keys() -> dict:
    with open(game_path, "r", encoding="utf-8") as f:
        game = f.read()
        centers_start_index = game.index("    self.P_CENTERS = {")
        centers_end_index = game.index("--All Consumeables", centers_start_index)
        joker_defs = game[centers_start_index:centers_end_index]
    
    res = findall(r"(j_[A-Za-z0-9_]+)\s*=.*?name\s*=\s*['\"]([^'\"]+)['\"]", joker_defs)
    return dict(res)


def export_keys(path: Path) -> Path:
    with open(path, "w") as f:
        joker_keys = get_keys()
        json.dump(joker_keys, f, indent=4)


export_keys(Path("./joker_map.json"))