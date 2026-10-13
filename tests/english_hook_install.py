#!/usr/bin/env python3
"""Ownership and validation regression for the standalone English hook."""
import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import english_hook_install as hook
from dotagents_lifecycle import RemovalPlan, codex_config_output


class HookInstallTests(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory(prefix="english hook '")
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name) / "codex config"
        self.root.mkdir()
        self.path = self.root / "hooks.json"

    def write(self, data):
        self.path.write_text(json.dumps(data))

    def snapshot(self):
        return {str(p.relative_to(self.root)): p.read_bytes() for p in self.root.rglob("*") if p.is_file()}

    def test_check_no_mutation_and_repeat(self):
        before = self.snapshot()
        hook.install(self.root, check=True)
        self.assertEqual(before, self.snapshot())
        hook.install(self.root)
        group = json.loads(self.path.read_text())["hooks"][hook.EVENT][0]
        self.assertEqual(group["hooks"][0]["additionalContextLimit"], 5000)
        self.assertEqual(json.loads((self.root / hook.LEDGER).read_text())["group"], group)
        before = self.snapshot()
        hook.install(self.root)
        self.assertEqual(before, self.snapshot())
        self.assertEqual(shlex.split(hook.owned_group(self.root)["hooks"][0]["command"]),
                         ["python3", str(self.root / "skills/ch-learn-english/scripts/english_state.py"), "hook"])

    def test_preserve_custom_groups_metadata_and_later_edits(self):
        original = {"description": "personal", "hooks": {hook.EVENT: [{"hooks": [
            {"type": "command", "command": "echo personal"}]}], "Stop": []}}
        self.write(original)
        hook.install(self.root)
        installed = json.loads(self.path.read_text())
        installed["hooks"][hook.EVENT][0]["hooks"][0]["command"] = "echo changed"
        installed["extra"] = "added afterwards"
        self.write(installed)
        plan = RemovalPlan()
        hook.plan_uninstall(plan, self.root)
        output = json.loads(plan.changes[self.path])
        self.assertEqual(output["hooks"][hook.EVENT][0]["hooks"][0]["command"], "echo changed")
        self.assertEqual(output["extra"], "added afterwards")
        self.assertEqual(output["hooks"]["Stop"], [])
        self.assertIn(self.root / hook.LEDGER, plan.changes)

    def test_user_edited_owned_group_is_never_removed_or_overwritten(self):
        hook.install(self.root)
        data = json.loads(self.path.read_text())
        data["hooks"][hook.EVENT][0]["hooks"].append({"type": "command", "command": "echo personal"})
        self.write(data)
        before = self.snapshot()
        with self.assertRaises(ValueError):
            hook.install(self.root)
        plan = RemovalPlan()
        hook.plan_uninstall(plan, self.root)
        self.assertFalse(plan.changes)
        self.assertEqual(before, self.snapshot())

    def test_unowned_exact_group_collision(self):
        self.write({"hooks": {hook.EVENT: [hook.owned_group(self.root)]}})
        before = self.snapshot()
        with self.assertRaisesRegex(ValueError, "Collision"):
            hook.install(self.root)
        self.assertEqual(before, self.snapshot())

    def test_equivalent_quoting_collision(self):
        group = hook.owned_group(self.root)
        script = self.root / "skills/ch-learn-english/scripts/english_state.py"
        group["hooks"][0]["command"] = 'python3 "' + str(script) + '" hook'
        self.write({"hooks": {hook.EVENT: [group]}})
        with self.assertRaisesRegex(ValueError, "Collision"):
            hook.install(self.root)

    def test_registered_command_executes_with_spaces_and_apostrophe(self):
        source = Path(__file__).resolve().parents[1] / "skills/ch-learn-english"
        destination = self.root / "skills/ch-learn-english"
        shutil.copytree(source, destination)
        hook.install(self.root)
        command = json.loads(self.path.read_text())["hooks"][hook.EVENT][0]["hooks"][0]["command"]
        result = subprocess.run(command, shell=True, input=json.dumps({
            "session_id": "installer-test", "prompt": "$ch-learn-english status"}),
            env=dict(os.environ, DOTAGENTS_ENGLISH_STATE_DIR=str(self.root / "personal-state")),
            capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(json.loads(result.stdout)["hookSpecificOutput"]["hookEventName"], hook.EVENT)

    def test_inline_collision_and_invalid_config(self):
        config = self.root / "config.toml"
        command = json.dumps(hook.owned_group(self.root)["hooks"][0]["command"])
        config.write_text('[[hooks.UserPromptSubmit]]\n[[hooks.UserPromptSubmit.hooks]]\ntype="command"\ncommand=' + command)
        with self.assertRaisesRegex(ValueError, "Collision"):
            hook.preflight(self.root)
        for invalid in ("invalid TOML", 'hooks = []', 'features = false', 'mcp_servers = "invalid"'):
            with self.subTest(invalid=invalid):
                config.write_text(invalid)
                before = self.snapshot()
                with self.assertRaises(ValueError):
                    hook.install(self.root)
                self.assertEqual(before, self.snapshot())

    def test_global_config_preflight_rejects_unsupported_inline_edit(self):
        path = self.root / "config.toml"
        for source in ('features = { personal = true }\n',
                       'features = { multi_agent = true }\nmcp_servers = { personal = {} }\n'):
            with self.subTest(source=source):
                path.write_text(source)
                before = self.snapshot()
                with self.assertRaisesRegex(ValueError, "Không hỗ trợ"):
                    hook.install(self.root, check=True, tune_config=True)
                self.assertEqual(before, self.snapshot())
                # Project hooks never tune config, so this valid TOML is fine there.
                hook.install(self.root, check=True)
                self.assertEqual(before, self.snapshot())

    def test_parsed_config_handles_inline_existing_keys_and_quoted_features(self):
        path = self.root / "config.toml"
        source = 'features = { multi_agent = false }\nmcp_servers = { playwright = { command = "personal" } }\n'
        path.write_text(source)
        original, output = codex_config_output(self.root)
        self.assertEqual(original, output)
        for header in ('["features"]', "['features']", '[ features ]'):
            with self.subTest(header=header):
                source = header + ' # heading comment\npersonal = true # keep comment\n'
                path.write_text(source)
                original, output = codex_config_output(self.root)
                self.assertEqual(original, source.encode())
                self.assertIn(header + ' # heading comment\nmulti_agent = true\n', output.decode())
                self.assertIn('personal = true # keep comment\n', output.decode())
                self.assertEqual(path.read_text(), source)

    def test_malformed_hooks_and_ledger(self):
        for data in ([], {"hooks": []}, {"hooks": {hook.EVENT: {}}},
                     {"hooks": {hook.EVENT: [{"hooks": "bad"}]}},
                     {"hooks": {hook.EVENT: [{"hooks": [{"type": "command", "command": 3}]}]}}):
            with self.subTest(data=data):
                self.write(data)
                with self.assertRaises(ValueError):
                    hook.install(self.root)
        self.write({})
        (self.root / hook.LEDGER).write_text('{}')
        with self.assertRaisesRegex(ValueError, "ledger"):
            hook.install(self.root)

    def test_duplicate_json_keys_and_null_ledger_refused(self):
        self.path.write_text('{"hooks": {}, "hooks": {"Stop": []}}')
        with self.assertRaisesRegex(ValueError, "trùng"):
            hook.install(self.root)
        self.write({})
        (self.root / hook.LEDGER).write_text('null')
        with self.assertRaisesRegex(ValueError, "ledger"):
            hook.install(self.root)

    def test_created_file_removal_and_duplicate_ambiguity(self):
        hook.install(self.root)
        plan = RemovalPlan()
        hook.plan_uninstall(plan, self.root)
        self.assertIsNone(plan.changes[self.path])
        self.write({"hooks": {hook.EVENT: [hook.owned_group(self.root)] * 2}})
        plan = RemovalPlan()
        hook.plan_uninstall(plan, self.root)
        self.assertFalse(plan.changes)

    def test_symlink_refused(self):
        target = self.root / "personal.json"
        target.write_text('{}')
        self.path.symlink_to(target)
        with self.assertRaises(ValueError):
            hook.install(self.root)
        self.assertEqual(target.read_text(), '{}')


if __name__ == "__main__":
    unittest.main()
