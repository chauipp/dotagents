#!/usr/bin/env python3
"""Ownership ledger and reversible uninstall for dotagents (Python 3.11+)."""
import argparse
import copy
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import stat
import subprocess
import sys
import tempfile
import tomllib

STATE = ".dotagents-state.json"
RULES = {"claude": "CLAUDE.md", "codex": "AGENTS.md"}
BEGIN = "<!-- dotagents:begin"
END = "<!-- dotagents:end -->"
IGNORE_BEGIN = "# dotagents:begin skills"
IGNORE_END = "# dotagents:end skills"
CONVERSATION_BEGIN = "# dotagents:begin conversations"
CONVERSATION_END = "# dotagents:end conversations"
PLUGIN = "superpowers@claude-plugins-official"


def safe_path(path, leaf_link=False):
    path = Path(os.path.abspath(path))
    for parent in reversed(path.parents):
        if parent.is_symlink():
            raise ValueError(f"Symlink trong đường dẫn: {parent}")
    if path.is_symlink() and not leaf_link:
        raise ValueError(f"Đích là symlink: {path}")
    return path


def load_json(path, default=None):
    safe_path(path)
    if not path.exists():
        return copy.deepcopy(default)
    with path.open() as f:
        return json.load(f)


def atomic_bytes(path, data, mode=None):
    safe_path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp = tempfile.mkstemp(prefix=".dotagents-write-", dir=path.parent)
    try:
        with os.fdopen(fd, "wb") as f:
            f.write(data)
            f.flush()
            os.fsync(f.fileno())
        if mode is not None:
            os.chmod(temp, mode)
        os.replace(temp, path)
    finally:
        if os.path.exists(temp):
            os.unlink(temp)


def json_bytes(data):
    return (json.dumps(data, ensure_ascii=False, indent=2) + "\n").encode()


def atomic_json(path, data):
    atomic_bytes(path, json_bytes(data), 0o600)


def read_state(root):
    state = load_json(root / STATE, {"version": 1, "agents": {}})
    if not isinstance(state, dict) or state.get("version") != 1 or not isinstance(state.get("agents"), dict):
        raise ValueError(f"Ledger không hợp lệ: {root / STATE}")
    for agent, record in state["agents"].items():
        if agent not in RULES or not isinstance(record, dict):
            raise ValueError("Agent trong ledger không hợp lệ")
        if "rules_created" in record and not isinstance(record["rules_created"], bool):
            raise ValueError("Rules ownership trong ledger không hợp lệ")
        if not isinstance(record.get("config", {}), dict):
            raise ValueError("Config ledger không hợp lệ")
        paths = record.get("global_ignores", [])
        if not isinstance(paths, list) or any(not isinstance(p, str) or not Path(p).is_absolute() for p in paths):
            raise ValueError("Global ignore ledger không hợp lệ")
        for key, entry in record.get("config", {}).items():
            if key not in config_specs(agent) or not isinstance(entry, dict):
                raise ValueError("Config key trong ledger không hợp lệ")
            for side in ("before", "after"):
                val = entry.get(side)
                if not isinstance(val, dict) or not isinstance(val.get("exists"), bool) or "value" not in val:
                    raise ValueError("Config state không hợp lệ")
    return state


def config_specs(agent):
    if agent == "claude":
        return {
            "plugin": ("settings.json", ("enabledPlugins", PLUGIN)),
            "coauthor": ("settings.json", ("includeCoAuthoredBy",)),
            "playwright": (".claude.json", ("mcpServers", "playwright")),
        }
    return {
        "multi_agent": ("config.toml", ("features", "multi_agent")),
        "playwright": ("config.toml", ("mcp_servers", "playwright")),
    }


def config_data(path):
    safe_path(path)
    if not path.exists():
        return {}
    if path.suffix == ".toml":
        with path.open("rb") as f:
            return tomllib.load(f)
    data = load_json(path)
    if not isinstance(data, dict):
        raise ValueError(f"Config không phải object: {path}")
    return data


def at_key(data, keys):
    obj = data
    for key in keys:
        if not isinstance(obj, dict) or key not in obj:
            return {"exists": False, "value": None}
        obj = obj[key]
    return {"exists": True, "value": obj}


def set_key(data, keys, value):
    obj = data
    if not value["exists"]:
        for key in keys[:-1]:
            if key not in obj:
                return
            obj = obj[key]
        obj.pop(keys[-1], None)
    else:
        for key in keys[:-1]:
            obj = obj.setdefault(key, {})
        obj[keys[-1]] = copy.deepcopy(value["value"])


def observed(root, agent, config=True):
    values = {}
    if config:
        for name, (filename, keys) in config_specs(agent).items():
            values[name] = at_key(config_data(root / filename), keys)
    return {"rules_exists": (root / RULES[agent]).exists(), "config": values}


def snapshot_install(args):
    root = safe_path(args.root)
    read_state(root)
    safe_path(root / RULES[args.agent])
    atomic_json(Path(args.output), observed(root, args.agent, args.config))


def toml_owned_text(path, key):
    """Track comments inside owned TOML edits, so user annotations are retained."""
    if not path.exists():
        return ""
    lines = path.read_text().splitlines(keepends=True)
    active = False
    chunk = []
    for line in lines:
        table = re.match(r"^\s*\[([^\]]+)\]\s*(?:#.*)?$", line.rstrip("\r\n"))
        if table:
            name = table.group(1).strip()
            if key == "multi_agent":
                active = name == "features"
            elif active:
                break
            elif name == "mcp_servers.playwright":
                active = True
                chunk.append(line)
                continue
        if active:
            if key == "multi_agent" and re.match(r"^\s*multi_agent\s*=", line):
                return line.rstrip()
            if key == "playwright":
                chunk.append(line)
    return "".join(chunk).rstrip()


def record_install(args):
    root = safe_path(args.root)
    state = read_state(root)
    before = load_json(Path(args.input))
    after = observed(root, args.agent, args.config)
    old = state["agents"].get(args.agent, {})
    record = copy.deepcopy(old)
    record["rules_created"] = bool(old.get("rules_created", False) or not before["rules_exists"])
    config = record.setdefault("config", {})
    for key, value in after["config"].items():
        previous = before["config"][key]
        if previous == value:
            continue
        existing = config.get(key)
        original = existing["before"] if existing and existing["after"] == previous else previous
        if original == value:
            config.pop(key, None)
        else:
            config[key] = {"before": original, "after": value}
            if args.agent == "codex":
                config[key]["after_text"] = toml_owned_text(root / "config.toml", key)
    state["agents"][args.agent] = record
    atomic_json(root / STATE, state)


def strip_block(data, begin, end):
    """Remove exactly one whole-line block, preserving every outside byte."""
    lines = data.splitlines(keepends=True)
    starts, ends = [], []
    for i, line in enumerate(lines):
        text = line.decode("utf-8").rstrip("\r\n")
        if begin in text:
            if not text.startswith(begin) or (begin == BEGIN and not text.endswith("-->")):
                raise ValueError("Begin marker không ở một dòng hợp lệ")
            if begin != BEGIN and text != begin:
                raise ValueError("Begin marker không hợp lệ")
            starts.append(i)
        if end in text:
            if text != end:
                raise ValueError("End marker không ở một dòng hợp lệ")
            ends.append(i)
    if not starts and not ends:
        return data, None
    if len(starts) != 1 or len(ends) != 1 or starts[0] >= ends[0]:
        raise ValueError("Marker thiếu, lồng hoặc không cân bằng")
    a, b = starts[0], ends[0]
    return b"".join(lines[:a] + lines[b + 1:]), (lines, a, b)


def global_ignore_path():
    result = subprocess.run(["git", "config", "--global", "--path", "--get", "core.excludesFile"],
                            capture_output=True, text=True)
    if result.returncode not in (0, 1):
        raise ValueError(f"Không đọc được Git global config: {result.stderr.strip()}")
    configured = result.returncode == 0
    if configured:
        value = result.stdout.rstrip("\n")
        if not value:
            raise ValueError("core.excludesFile rỗng; hãy cấu hình đường dẫn hợp lệ")
        path = Path(value)
    else:
        path = Path(os.environ.get("XDG_CONFIG_HOME") or str(Path.home() / ".config")) / "git/ignore"
    return safe_path(path), configured


def install_global_ignore(args):
    path, configured = global_ignore_path()
    original = path.read_bytes() if path.exists() else b""
    outside, _ = strip_block(original, CONVERSATION_BEGIN, CONVERSATION_END)
    roots = [safe_path(root) for root in args.root]
    states = [read_state(root) for root in roots]
    print(f"  ignore global -> {path} (conversation/)")
    if args.check:
        return
    separator = b"" if not outside or outside.endswith(b"\n\n") else (b"\n" if outside.endswith(b"\n") else b"\n\n")
    block = (CONVERSATION_BEGIN + "\nconversation/\n" + CONVERSATION_END + "\n").encode()
    output = outside + separator + block
    if original != output:
        atomic_bytes(path, output, stat.S_IMODE(path.stat().st_mode) if path.exists() else 0o600)
    if not configured:
        subprocess.run(["git", "config", "--global", "core.excludesFile", str(path)], check=True)
    for root, state in zip(roots, states):
        for record in state["agents"].values():
            paths = record.setdefault("global_ignores", [])
            if str(path) not in paths:
                paths.append(str(path))
        atomic_json(root / STATE, state)


def plan_global_ignore(plan, paths):
    for value in sorted(set(paths)):
        path = safe_path(value)
        if not path.exists():
            continue
        output, block = strip_block(path.read_bytes(), CONVERSATION_BEGIN, CONVERSATION_END)
        if block:
            plan.roots.add(path.parent)
            plan.change(path, output)


def fingerprint(path):
    path = safe_path(path, leaf_link=True)
    if path.is_symlink():
        return {"type": "link", "target": os.readlink(path)}
    if not path.exists():
        return {"type": "missing"}
    mode = stat.S_IMODE(path.stat().st_mode)
    if path.is_file():
        return {"type": "file", "hash": hashlib.sha256(path.read_bytes()).hexdigest(), "mode": mode}
    if path.is_dir():
        result = []
        for item in sorted(path.iterdir()):
            result.append([item.name, fingerprint(item)])
        return {"type": "dir", "entries": result, "mode": mode}
    raise ValueError(f"Loại file không hỗ trợ: {path}")


def remove(path):
    safe_path(path, leaf_link=True)
    if path.is_symlink() or path.is_file():
        path.unlink()
    elif path.exists():
        shutil.rmtree(path)


def payload_copy(src, dst):
    if src.is_symlink():
        dst.symlink_to(os.readlink(src))
    elif src.is_dir():
        shutil.copytree(src, dst, symlinks=True)
    elif src.exists():
        shutil.copy2(src, dst)


def without_empty_tables(value):
    if isinstance(value, dict):
        return {key: without_empty_tables(item) for key, item in value.items()
                if item != {}}
    return value


def render_toml(original, key, before):
    """Only edit installer-owned boolean assignment or its added MCP table."""
    lines = original.decode().splitlines(keepends=True)
    if key == "multi_agent":
        active = False
        found = []
        for i, line in enumerate(lines):
            table = re.match(r"^\s*\[([^\]]+)\]\s*(?:#.*)?$", line.rstrip("\r\n"))
            if table:
                active = table.group(1).strip() == "features"
            if active and re.match(r"^\s*multi_agent\s*=", line):
                found.append(i)
        if len(found) != 1:
            raise ValueError("Không thể sửa features.multi_agent an toàn trong cấu trúc TOML này")
        i = found[0]
        if before["exists"]:
            if not isinstance(before["value"], bool):
                raise ValueError("multi_agent cũ không phải boolean")
            # Keep inline comment and surrounding unrelated lines.
            comment = lines[i].partition("#")[2].rstrip("\r\n")
            lines[i] = "multi_agent = " + str(before["value"]).lower() + (" #" + comment if comment else "") + "\n"
        else:
            lines.pop(i)
    else:
        if before["exists"]:
            raise ValueError("Không hỗ trợ thay bảng MCP có sẵn; installer chỉ thêm bảng thiếu")
        start = None
        stop = len(lines)
        for i, line in enumerate(lines):
            table = re.match(r"^\s*\[([^\]]+)\]\s*(?:#.*)?$", line.rstrip("\r\n"))
            if table:
                name = table.group(1).strip()
                if name == "mcp_servers.playwright":
                    if start is not None:
                        raise ValueError("Bảng MCP trùng")
                    start = i
                elif start is not None:
                    if name.startswith("mcp_servers.playwright."):
                        raise ValueError("Không gỡ bảng con MCP chưa được installer ghi")
                    stop = i
                    break
        if start is None:
            raise ValueError("Không tìm thấy bảng MCP có thể gỡ")
        del lines[start:stop]
    return "".join(lines).encode()


class RemovalPlan:
    def __init__(self):
        self.changes = {}
        self.before = {}
        self.messages = []
        self.roots = set()

    def change(self, path, data=None):
        path = safe_path(path, leaf_link=data is None)
        if data is not None and not path.exists():
            raise ValueError(f"Không sửa file không tồn tại: {path}")
        if data is not None and path.read_bytes() == data:
            return
        if data is None and not path.exists() and not path.is_symlink():
            return
        self.before.setdefault(path, fingerprint(path))
        self.changes[path] = data

    def note(self, message):
        self.messages.append(message)

    def report(self):
        for message in self.messages:
            print(message)
        for path, data in self.changes.items():
            print(("GỠ  " if data is None else "SỬA ") + str(path))
        print(f"Kế hoạch: {len(self.changes)} đích thay đổi; {len(self.messages)} mục giữ lại/lưu ý.")


def plan_agent(plan, root, agent, project, rules_only, state):
    root = safe_path(root)
    plan.roots.add(root)
    record = copy.deepcopy(state["agents"].get(agent, {}))
    rules = safe_path(root / RULES[agent])
    if rules.exists():
        original = rules.read_bytes()
        output, block = strip_block(original, BEGIN, END)
        if block:
            if not output.strip() and record.get("rules_created"):
                plan.change(rules)
            else:
                plan.change(rules, output)
            record.pop("rules_created", None)
        else:
            plan.note(f"GIỮ {rules}: không có block dotagents")
    if not rules.exists():
        record.pop("rules_created", None)
    cleared = False
    if not rules_only:
        if not project:
            record.pop("global_ignores", None)
        skills = safe_path(root / (("." + agent + "/skills") if project else "skills"))
        manifest = safe_path(skills / ".dotagents-manifest")
        if manifest.exists():
            names = manifest.read_text().splitlines()
            for name in names:
                if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]*", name) or name in (".", "..", ".system"):
                    raise ValueError(f"Tên skill manifest không hợp lệ: {name!r}")
            if len(names) != len(set(names)):
                raise ValueError(f"Manifest trùng tên: {manifest}")
            for name in names:
                path = skills / name
                # Unlink a skill symlink itself, never traverse its target.
                plan.change(path)
            plan.change(manifest)
            cleared = True
        elif skills.exists():
            plan.note(f"GIỮ {skills}: thiếu manifest, không đoán ownership")
        else:
            cleared = True
        if not project:
            pending = {}
            grouped = {}
            for key, entry in record.get("config", {}).items():
                filename, keys = config_specs(agent)[key]
                path = safe_path(root / filename)
                data = grouped.setdefault(path, config_data(path))
                current = at_key(data, keys)
                if current == entry["before"]:
                    continue
                if current != entry["after"] or (path.suffix == ".toml" and "after_text" in entry
                                               and toml_owned_text(path, key) != entry["after_text"]):
                    pending[key] = entry
                    plan.note(f"GIỮ {path} ({key}): người dùng đã sửa sau cài")
                    continue
                set_key(data, keys, entry["before"])
                if path.suffix == ".toml":
                    original = plan.changes.get(path, path.read_bytes())
                    output = render_toml(original, key, entry["before"])
                    if without_empty_tables(tomllib.loads(output.decode())) != without_empty_tables(data):
                        raise ValueError(f"TOML restore thay đổi dữ liệu ngoài ownership: {path}")
                    plan.change(path, output)
                else:
                    plan.change(path, json_bytes(data))
            if not record.get("config"):
                plan.note(f"GIỮ config {root}: không có key thuộc ledger dotagents")
            record["config"] = pending
    if record.get("rules_created") or record.get("config") or record.get("global_ignores"):
        state["agents"][agent] = record
    else:
        state["agents"].pop(agent, None)
    return cleared


def plan_ignore(plan, root, agents):
    path = safe_path(root / ".gitignore")
    if not path.exists() or not agents:
        return
    original = path.read_bytes()
    outside, block = strip_block(original, IGNORE_BEGIN, IGNORE_END)
    if block is None:
        return
    lines, a, b = block
    prefixes = tuple(("." + agent + "/skills/").encode() for agent in agents)
    kept = [line for line in lines[a + 1:b] if not line.rstrip(b"\r\n").startswith(prefixes)]
    if plan.changes.get(root / STATE, b"keep") is None or not (root / STATE).exists():
        kept = [line for line in kept if line.rstrip(b"\r\n") != STATE.encode()]
    meaningful = [line for line in kept if line.strip() and not line.lstrip().startswith(b"#")]
    output = b"".join(lines[:a] + [lines[a]] + kept + [lines[b]] + lines[b + 1:]) if meaningful else outside
    plan.change(path, output)


def finish_state(plan, root, state):
    path = safe_path(root / STATE)
    if not path.exists():
        return
    if state["agents"]:
        plan.change(path, json_bytes(state))
    else:
        plan.change(path)


def apply_plan(plan, backup_parent):
    plan.report()
    if not plan.changes:
        print("Không có dữ liệu dotagents cần gỡ.")
        return
    backup_parent = safe_path(backup_parent)
    for path, expected in plan.before.items():
        if fingerprint(path) != expected:
            raise ValueError(f"Đích đã đổi sau preflight: {path}")
    for path in plan.changes:
        if backup_parent == path or path in backup_parent.parents:
            raise ValueError("Backup không được nằm trong đường dẫn sẽ gỡ")
    backup_parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    backup = Path(tempfile.mkdtemp(prefix=datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ-"), dir=backup_parent))
    journal = {"version": 1, "roots": sorted(map(str, plan.roots)), "phase": "prepared", "entries": []}
    try:
        # Capture all data before the first mutation.
        for i, (path, data) in enumerate(plan.changes.items()):
            before = plan.before[path]
            if fingerprint(path) != before:
                raise ValueError(f"Đích đã đổi sau preflight: {path}")
            dest = backup / str(i)
            payload_copy(path, dest)
            if fingerprint(dest) != before:
                raise ValueError(f"Backup không khớp dữ liệu trước gỡ: {path}")
            mode = before.get("mode", 0o600)
            after = {"type": "missing"} if data is None else {
                "type": "file", "hash": hashlib.sha256(data).hexdigest(), "mode": mode}
            journal["entries"].append({"path": str(path), "payload": str(i), "before": before, "after": after})
        atomic_json(backup / "journal.json", journal)
        for entry, (path, data) in zip(journal["entries"], plan.changes.items()):
            if fingerprint(path) != entry["before"]:
                raise ValueError(f"Đích đã đổi sau preflight: {path}")
            if data is None:
                remove(path)
            else:
                atomic_bytes(path, data, entry["before"].get("mode", 0o600))
        journal["phase"] = "complete"
        atomic_json(backup / "journal.json", journal)
        print(f"Backup: {backup}\nKhôi phục: uninstall.sh --restore '{backup}'")
    except BaseException:
        print(f"Gỡ chưa hoàn tất. Backup/restore: {backup}", file=sys.stderr)
        raise


def restore(backup, check):
    backup = safe_path(backup)
    journal = load_json(backup / "journal.json")
    if not isinstance(journal, dict) or journal.get("version") != 1:
        raise ValueError("Journal không hợp lệ")
    roots = [safe_path(root) for root in journal["roots"]]
    work = []
    for i, entry in enumerate(journal["entries"]):
        path = safe_path(entry["path"], leaf_link=True)
        if not any(root in path.parents for root in roots):
            raise ValueError(f"Restore path ngoài đích: {path}")
        if entry["payload"] != str(i):
            raise ValueError("Backup payload không hợp lệ")
        payload = backup / str(i)
        if fingerprint(payload) != entry["before"]:
            raise ValueError(f"Backup bị sửa hoặc thiếu: {payload}")
        current = fingerprint(path)
        if current == entry["before"]:
            continue
        if current != entry["after"]:
            raise ValueError(f"Đích đã được sửa sau uninstall; không ghi đè: {path}")
        work.append((path, payload, entry["after"]))
    for path, _, _ in work:
        print("RESTORE " + str(path))
    if check:
        return
    for path, payload, expected in work:
        if fingerprint(path) != expected:
            raise ValueError(f"Đích đã đổi sau restore preflight: {path}")
        path.parent.mkdir(parents=True, exist_ok=True)
        if payload.is_file() and not payload.is_symlink():
            atomic_bytes(path, payload.read_bytes(), stat.S_IMODE(payload.stat().st_mode))
        else:
            temp = Path(tempfile.mkdtemp(prefix=".dotagents-restore-", dir=path.parent))
            try:
                staged = temp / "payload"
                payload_copy(payload, staged)
                os.replace(staged, path)
            finally:
                shutil.rmtree(temp)
    print("Khôi phục hoàn tất; backup vẫn được giữ.")


def uninstall(args):
    if args.restore:
        if args.project is not None or args.claude or args.codex or args.all or args.rules_only:
            raise ValueError("--restore chỉ kết hợp với --check và --backup-dir")
        restore(args.restore, args.check)
        return
    agents = [name for name in RULES if args.all or getattr(args, name)]
    project = args.project is not None
    if project:
        root = safe_path(args.project)
        if not root.is_dir():
            raise ValueError(f"Project không tồn tại: {root}")
        agents = agents or list(RULES)
        roots = {name: root for name in agents}
    else:
        roots = {"claude": safe_path(os.environ.get("CLAUDE_CONFIG_DIR", str(Path.home() / ".claude"))),
                 "codex": safe_path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex")))}
        agents = agents or [name for name, root in roots.items() if root.is_dir()]
    plan = RemovalPlan()
    states = {}
    cleared = []
    global_ignores = []
    for agent in agents:
        root = roots[agent]
        if root not in states:
            states[root] = read_state(root)
        if not project and not args.rules_only:
            global_ignores.extend(states[root]["agents"].get(agent, {}).get("global_ignores", []))
        if plan_agent(plan, root, agent, project, args.rules_only, states[root]):
            cleared.append(agent)
    for root, state in states.items():
        finish_state(plan, root, state)
    if project and not args.rules_only:
        plan_ignore(plan, roots[agents[0]], cleared)
    elif not project and not args.rules_only:
        plan_global_ignore(plan, global_ignores)
    if args.check:
        plan.report()
        print("CHECK: không ghi file hoặc tạo backup.")
    else:
        apply_plan(plan, Path(args.backup_dir))


def main():
    parser = argparse.ArgumentParser(description="Gỡ dotagents theo ownership, giữ dữ liệu riêng; Python 3.11+.")
    subs = parser.add_subparsers(dest="command", required=True)
    for command in ("snapshot", "record"):
        p = subs.add_parser(command)
        p.add_argument("root", type=Path)
        p.add_argument("agent", choices=RULES)
        p.add_argument("output" if command == "snapshot" else "input", type=Path)
        p.add_argument("--config", action="store_true")
    p = subs.add_parser("uninstall")
    p.add_argument("--project", nargs="?", const=os.getcwd())
    p.add_argument("--claude", action="store_true")
    p.add_argument("--codex", action="store_true")
    p.add_argument("--all", action="store_true")
    p.add_argument("--rules-only", action="store_true")
    p.add_argument("--check", action="store_true")
    p.add_argument("--restore", type=Path)
    p.add_argument("--backup-dir", default=str(Path.home() / ".local/state/dotagents/uninstall"))
    p = subs.add_parser("global-ignore")
    p.add_argument("--root", type=Path, action="append", default=[])
    p.add_argument("--check", action="store_true")
    args = parser.parse_args()
    try:
        if args.command == "snapshot":
            snapshot_install(args)
        elif args.command == "record":
            record_install(args)
        elif args.command == "global-ignore":
            install_global_ignore(args)
        else:
            uninstall(args)
    except (OSError, ValueError, KeyError, TypeError, subprocess.CalledProcessError) as error:
        print(f"LỖI: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
