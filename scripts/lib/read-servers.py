#!/usr/bin/env python3
import csv
import json
import pathlib
import sys


def norm_bool(value):
    if isinstance(value, bool):
        return "true" if value else "false"
    return str(value).strip().lower() == "true" and "true" or "false"


def from_json(path):
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, list):
        raise ValueError("servers.json must contain array")

    for row in data:
        yield [
            str(row.get("name", "")).strip(),
            str(row.get("container", "")).strip(),
            str(row.get("service", "")).strip(),
            str(row.get("host", "")).strip(),
            str(row.get("port", "")).strip(),
            str(row.get("worldborder_center_x", "")).strip(),
            str(row.get("worldborder_center_z", "")).strip(),
            str(row.get("worldborder_diameter", "")).strip(),
            str(row.get("pregeneration_radius", "")).strip(),
            norm_bool(row.get("pregeneration_enabled", False)),
            norm_bool(row.get("gen_map", False)),
        ]


def from_conf(path):
    with path.open(newline="", encoding="utf-8") as f:
        reader = csv.reader(f, delimiter="|")
        for row in reader:
            if not row:
                continue
            name = row[0].strip() if len(row) > 0 else ""
            if not name or name.startswith("#"):
                continue
            row = [part.strip() for part in row]
            row += [""] * (11 - len(row))
            yield row[:11]


def main():
    repo_root = pathlib.Path(__file__).resolve().parents[2]
    json_path = repo_root / "config" / "servers.json"
    conf_path = repo_root / "config" / "servers.conf"

    rows = None
    if json_path.exists():
        rows = from_json(json_path)
    elif conf_path.exists():
        rows = from_conf(conf_path)
    else:
        print("ERROR: neither config/servers.json nor config/servers.conf found.", file=sys.stderr)
        sys.exit(1)

    for row in rows:
        print("|".join(row))


if __name__ == "__main__":
    main()
