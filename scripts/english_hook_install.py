#!/usr/bin/env python3
"""Register one Codex hook group, with conservative, separate ownership."""
import argparse
import copy
import json
from pathlib import Path
import shlex
import sys

sys.dont_write_bytecode = True
from dotagents_lifecycle import atomic_json, codex_config_output, config_data, json_bytes, safe_path

LEDGER = ".dotagents-english-hook.json"
EVENT = "UserPromptSubmit"


def unique_object(pairs):
    data = {}
    for key, value in pairs:
        if key in data:
            raise ValueError(f"JSON key bị trùng, giữ file để sửa: {key}")
        data[key] = value
    return data


def read_json(path, default=None):
    safe_path(path)
    if not path.exists():
        return copy.deepcopy(default)
    with path.open(encoding="utf-8") as stream:
        return json.load(stream, object_pairs_hook=unique_object)


def owned_group(root):
    script = root / "skills/ch-learn-english/scripts/english_state.py"
    return {"hooks": [{"type": "command", "command": "python3 " + shlex.quote(str(script)) + " hook",
                       "timeout": 10, "additionalContextLimit": 5000}]}


def validate_hooks(data, path):
    if not isinstance(data, dict) or not isinstance(data.get("hooks", {}), dict):
        raise ValueError(f"Hooks config không phải object: {path}")
    for event, groups in data.get("hooks", {}).items():
        if not isinstance(groups, list):
            raise ValueError(f"Hook event không phải array: {path} ({event})")
        for group in groups:
            if not isinstance(group, dict) or not isinstance(group.get("hooks"), list):
                raise ValueError(f"Hook group không hợp lệ: {path} ({event})")
            if "matcher" in group and not isinstance(group["matcher"], str):
                raise ValueError(f"Hook matcher không hợp lệ: {path}")
            for handler in group["hooks"]:
                if not isinstance(handler, dict) or not isinstance(handler.get("type"), str):
                    raise ValueError(f"Hook handler không hợp lệ: {path}")
                if handler["type"] == "command" and not isinstance(handler.get("command"), str):
                    raise ValueError(f"Hook command không hợp lệ: {path}")


def read_owned(root):
    path = root / LEDGER
    ledger = read_json(path)
    if path.exists() and (not isinstance(ledger, dict) or ledger.get("version") != 1
                              or ledger.get("group") != owned_group(root)
                              or not isinstance(ledger.get("file_created"), bool)):
        raise ValueError(f"English hook ledger không hợp lệ: {root / LEDGER}")
    return ledger


def read_hooks(root):
    path = safe_path(root / "hooks.json")
    data = read_json(path, {})
    validate_hooks(data, path)
    return data


def preflight(root, tune_config=False):
    root = safe_path(root)
    data = read_hooks(root)
    ledger = read_owned(root)
    config = config_data(root / "config.toml")
    if tune_config:
        codex_config_output(root)
    inline_hooks = config.get("hooks", {})
    if isinstance(inline_hooks, dict):
        # Codex stores hook trust metadata under [hooks.state]. It is not an
        # inline hook event and therefore does not have the event-array shape.
        inline_hooks = {event: groups for event, groups in inline_hooks.items()
                        if event != "state"}
    inline = {"hooks": inline_hooks}
    validate_hooks(inline, root / "config.toml")
    # Reject invalid containers before tune_codex_config can append into them.
    for key in ("features", "mcp_servers"):
        if key in config and not isinstance(config[key], dict):
            raise ValueError(f"Config {key} không phải table: {root / 'config.toml'}")
    desired = owned_group(root)
    groups = data.get("hooks", {}).get(EVENT, [])
    if ledger and groups.count(ledger["group"]) != 1:
        raise ValueError(f"Collision: group hook thuộc ledger đã sửa hoặc trùng; giữ nguyên: {root}")
    command = desired["hooks"][0]["command"]
    for source in (data, inline):
        for event, entries in source.get("hooks", {}).items():
            for group in entries:
                if source is data and event == EVENT and ledger and group == ledger["group"]:
                    continue
                if any(same_command(h.get("command"), command) for h in group["hooks"]):
                    raise ValueError(f"Collision: English hook có sẵn ngoài ownership: {root}")
    return root, data, ledger


def same_command(left, right):
    if not isinstance(left, str):
        return False
    try:
        return shlex.split(left) == shlex.split(right)
    except ValueError:
        return left == right


def install(root, check=False, tune_config=False):
    root, data, ledger = preflight(root, tune_config)
    if check:
        print(f"  hook   -> {root / 'hooks.json'} (English, chỉ kiểm tra)")
        return
    if not ledger:
        created = not (root / "hooks.json").exists()
        data.setdefault("hooks", {}).setdefault(EVENT, []).append(owned_group(root))
        atomic_json(root / "hooks.json", data)
        atomic_json(root / LEDGER, {"version": 1, "group": owned_group(root), "file_created": created})
    print(f"  hook   -> {root / 'hooks.json'} (ch-learn-english; cần review/trust trong Codex)")


def plan_uninstall(plan, root):
    root = safe_path(root)
    ledger = read_owned(root)
    if not ledger:
        return
    path = root / "hooks.json"
    data = read_hooks(root)
    groups = data.get("hooks", {}).get(EVENT, [])
    if groups.count(ledger["group"]) != 1:
        plan.note(f"GIỮ {path} và ledger: group English đã sửa, mất hoặc trùng; không đoán ownership")
        return
    output = copy.deepcopy(data)
    output["hooks"][EVENT].remove(ledger["group"])
    if not output["hooks"][EVENT]:
        del output["hooks"][EVENT]
    if not output["hooks"]:
        del output["hooks"]
    plan.change(path, None if ledger["file_created"] and not output else json_bytes(output))
    plan.change(root / LEDGER)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path)
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--tune-config", action="store_true", help="Preflight global Codex config edits")
    args = parser.parse_args()
    try:
        install(args.root, args.check, args.tune_config)
    except (OSError, ValueError, TypeError) as error:
        print(f"LỖI: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
