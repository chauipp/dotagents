#!/usr/bin/env python3
"""Regression for real install/uninstall against isolated targets."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
import sys
from unittest import mock

sys.dont_write_bytecode = True

KIT = Path(__file__).resolve().parents[1]


class UninstallTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name)
        self.project = self.base / "project"
        self.project.mkdir()
        subprocess.run(["git", "init", "-q", str(self.project)], check=True)
        self.env = dict(os.environ, CODEX_HOME=str(self.base / "codex"),
                        CLAUDE_CONFIG_DIR=str(self.base / "claude"),
                        GIT_CONFIG_GLOBAL=str(self.base / "gitconfig"),
                        XDG_CONFIG_HOME=str(self.base / "xdg"))
        self.backups = self.base / "backups"

    def run_script(self, script, *args, ok=True):
        r = subprocess.run(["bash", str(KIT / script), *map(str, args)],
                           env=self.env, capture_output=True, text=True)
        if ok:
            self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        else:
            self.assertNotEqual(r.returncode, 0, r.stdout + r.stderr)
        return r

    def install(self, *args):
        return self.run_script("install.sh", *args)

    def uninstall(self, *args, ok=True):
        return self.run_script("uninstall.sh", "--backup-dir", self.backups, *args, ok=ok)

    def snapshot(self):
        result = {}
        for p in self.base.rglob("*"):
            if p.is_symlink():
                result[str(p.relative_to(self.base))] = ("link", os.readlink(p))
            elif p.is_file():
                result[str(p.relative_to(self.base))] = p.read_bytes()
            elif p.is_dir():
                result[str(p.relative_to(self.base))] = ("dir",)
        return result

    def backup(self):
        return next(self.backups.iterdir())

    def test_project_preservation_check_restore(self):
        for name in ["AGENTS.md", "CLAUDE.md"]:
            (self.project / name).write_text("private rules\n")
        (self.project / ".gitignore").write_text("private-ignore\n")
        self.install("--project", self.project)
        custom = self.project / ".codex/skills/my-project-skill"
        custom.mkdir()
        (custom / "SKILL.md").write_text("private skill")
        managed = self.project / ".codex/skills/brainstorming/SKILL.md"
        managed.write_text("locally edited kit")
        before = self.snapshot()
        self.uninstall("--project", self.project, "--all", "--check")
        self.assertEqual(before, self.snapshot())
        self.uninstall("--project", self.project, "--codex")
        self.assertEqual((self.project / "AGENTS.md").read_text(), "private rules\n\n")
        self.assertIn("dotagents:begin", (self.project / "CLAUDE.md").read_text())
        self.assertTrue(custom.exists())
        self.assertFalse(managed.exists())
        self.assertIn(".claude/skills/", (self.project / ".gitignore").read_text())
        self.assertNotIn(".codex/skills/", (self.project / ".gitignore").read_text())
        self.uninstall("--restore", self.backup())
        self.assertEqual(managed.read_text(), "locally edited kit")
        self.assertIn("dotagents:begin", (self.project / "AGENTS.md").read_text())

    def test_global_ignore_install_check_uninstall_restore(self):
        ignore = self.base / "xdg/git/ignore"
        ignore.parent.mkdir(parents=True)
        ignore.write_bytes(b"private-pattern\n")
        self.install("--codex", "--check")
        self.assertEqual(ignore.read_bytes(), b"private-pattern\n")
        self.install("--codex", "--rules-only")
        self.assertEqual(ignore.read_bytes(), b"private-pattern\n")
        self.assertFalse((self.base / "gitconfig").exists())
        self.install("--codex")
        installed = ignore.read_bytes()
        self.install("--codex")
        self.assertEqual(installed, ignore.read_bytes())
        self.assertEqual(installed.count(b"# dotagents:begin conversations"), 1)
        for repo in (self.project, self.base / "another-project"):
            repo.mkdir(exist_ok=True)
            subprocess.run(["git", "init", "-q", str(repo)], env=self.env, check=True)
            subprocess.run(["git", "-C", str(repo), "check-ignore", "-q",
                            "conversation/example.md"], env=self.env, check=True)
        before = self.snapshot()
        self.uninstall("--codex", "--check")
        self.assertEqual(before, self.snapshot())
        self.uninstall("--codex", "--rules-only")
        self.assertEqual(installed, ignore.read_bytes())
        self.install("--codex")
        self.uninstall("--codex")
        self.assertNotIn(b"dotagents:begin conversations", ignore.read_bytes())
        self.assertTrue(ignore.read_bytes().startswith(b"private-pattern\n"))
        backup = sorted(self.backups.iterdir())[-1]
        self.uninstall("--restore", backup)
        self.assertEqual(installed, ignore.read_bytes())

    def test_custom_global_ignore_and_changed_git_config(self):
        ignore = self.base / "custom ignore"
        ignore.write_bytes(b"# private\nprivate-file")
        subprocess.run(["git", "config", "--global", "core.excludesFile", str(ignore)],
                       env=self.env, check=True)
        self.install("--all")
        self.assertIn(b"conversation/", ignore.read_bytes())
        alternate = self.base / "alternate-ignore"
        alternate.write_text("another-rule\n")
        subprocess.run(["git", "config", "--global", "core.excludesFile", str(alternate)],
                       env=self.env, check=True)
        self.uninstall("--all")
        self.assertNotIn(b"dotagents:begin conversations", ignore.read_bytes())
        self.assertTrue(ignore.read_bytes().startswith(b"# private\nprivate-file"))
        self.assertEqual(alternate.read_text(), "another-rule\n")

    def test_global_ignore_malformed_marker_preflight(self):
        ignore = self.base / "xdg/git/ignore"
        ignore.parent.mkdir(parents=True)
        ignore.write_text("# dotagents:begin conversations\nconversation/\n")
        before = self.snapshot()
        self.run_script("install.sh", "--codex", ok=False)
        self.assertEqual(before, self.snapshot())

    def test_global_ignore_removes_all_recorded_paths(self):
        self.install("--all")
        first = self.base / "xdg/git/ignore"
        second = self.base / "second-ignore"
        subprocess.run(["git", "config", "--global", "core.excludesFile", str(second)],
                       env=self.env, check=True)
        self.install("--codex")
        self.uninstall("--codex")
        self.assertNotIn(b"dotagents:begin conversations", first.read_bytes())
        self.assertNotIn(b"dotagents:begin conversations", second.read_bytes())
        self.assertTrue((Path(self.env["CLAUDE_CONFIG_DIR"]) / "CLAUDE.md").exists())

    def test_rules_only_then_full_and_repeat(self):
        self.install("--project", self.project)
        self.uninstall("--project", self.project, "--rules-only")
        self.assertFalse((self.project / "AGENTS.md").exists())
        self.assertTrue((self.project / ".codex/skills/brainstorming").exists())
        self.assertIn("dotagents:begin skills", (self.project / ".gitignore").read_text())
        self.uninstall("--project", self.project, "--all")
        self.assertFalse((self.project / ".codex/skills/.dotagents-manifest").exists())
        self.assertNotIn("dotagents:begin skills", (self.project / ".gitignore").read_text())
        count = len(list(self.backups.iterdir()))
        self.uninstall("--project", self.project, "--all")
        self.assertEqual(count, len(list(self.backups.iterdir())))

    def test_malformed_marker_prevents_all_mutation(self):
        self.install("--project", self.project)
        p = self.project / "CLAUDE.md"
        p.write_text(p.read_text().replace("<!-- dotagents:end -->", ""))
        before = self.snapshot()
        r = self.uninstall("--project", self.project, ok=False)
        self.assertIn("LỖI:", r.stderr)
        self.assertEqual(before, self.snapshot())

    def test_manifest_traversal_and_symlink_parent(self):
        self.install("--project", self.project)
        manifest = self.project / ".codex/skills/.dotagents-manifest"
        old = manifest.read_text()
        manifest.write_text("../outside\n")
        before = self.snapshot()
        r = self.uninstall("--project", self.project, ok=False)
        self.assertIn("LỖI:", r.stderr)
        self.assertEqual(before, self.snapshot())
        manifest.write_text(old)
        skills = self.project / ".codex/skills"
        moved = self.project / "moved-skills"
        skills.rename(moved)
        skills.symlink_to(moved, target_is_directory=True)
        before = self.snapshot()
        r = self.uninstall("--project", self.project, ok=False)
        self.assertIn("LỖI:", r.stderr)
        self.assertEqual(before, self.snapshot())

    def test_legacy_keeps_unknown_files_and_config(self):
        root = Path(self.env["CODEX_HOME"])
        root.mkdir()
        (root / "AGENTS.md").write_text("legacy without marker\n")
        skills = root / "skills/brainstorming"
        skills.mkdir(parents=True)
        (skills / "SKILL.md").write_text("unknown ownership")
        (root / "config.toml").write_text("[features]\nmulti_agent = true\n")
        self.uninstall("--codex")
        self.assertTrue(skills.exists())
        self.assertIn("multi_agent = true", (root / "config.toml").read_text())
        self.assertEqual((root / "AGENTS.md").read_text(), "legacy without marker\n")

    def test_global_config_restore_and_reinstall(self):
        claude = Path(self.env["CLAUDE_CONFIG_DIR"])
        claude.mkdir()
        original = {"includeCoAuthoredBy": True, "private": "keep",
                    "enabledPlugins": {"superpowers@claude-plugins-official": True}}
        (claude / "settings.json").write_text(json.dumps(original))
        self.install("--all")
        self.install("--all")
        self.uninstall("--all")
        settings = json.loads((claude / "settings.json").read_text())
        self.assertEqual(settings, original)
        mcp = json.loads((claude / ".claude.json").read_text())
        self.assertNotIn("playwright", mcp.get("mcpServers", {}))
        codex = Path(self.env["CODEX_HOME"])
        self.assertNotIn("multi_agent", (codex / "config.toml").read_text())
        self.assertNotIn("mcp_servers.playwright", (codex / "config.toml").read_text())

    def test_changed_config_is_kept(self):
        self.install("--codex")
        p = Path(self.env["CODEX_HOME"]) / "config.toml"
        s = p.read_text().replace("multi_agent = true", "multi_agent = false")
        p.write_text(s + "\n[private]\nvalue = 42\n")
        r = self.uninstall("--codex")
        self.assertIn("multi_agent = false", p.read_text())
        self.assertIn("value = 42", p.read_text())
        self.assertIn("GIỮ", r.stdout)

    def test_restore_conflict_preflight(self):
        self.install("--project", self.project)
        self.uninstall("--project", self.project)
        p = self.project / "AGENTS.md"
        p.write_text("new user content\n")
        before = self.snapshot()
        self.uninstall("--restore", self.backup(), ok=False)
        self.assertEqual(before, self.snapshot())

    def test_codex_only_project_and_claude_only_removal(self):
        self.install("--project", self.project, "--codex")
        self.assertTrue((self.project / ".gitignore").exists())
        self.uninstall("--project", self.project, "--claude")
        self.assertTrue((self.project / "AGENTS.md").exists())
        self.uninstall("--project", self.project, "--codex")
        self.assertFalse((self.project / "AGENTS.md").exists())

    def test_existing_config_and_system_skill_remain(self):
        root = Path(self.env["CODEX_HOME"])
        root.mkdir()
        original = '[features]\nmulti_agent = false\n[private]\nvalue = 42\n'
        (root / "config.toml").write_text(original)
        system = root / "skills/.system"
        system.mkdir(parents=True)
        (system / "SKILL.md").write_text("system skill")
        self.install("--codex")
        self.uninstall("--codex")
        self.assertTrue(system.exists())
        self.assertIn("multi_agent = false", (root / "config.toml").read_text())
        self.assertIn("value = 42", (root / "config.toml").read_text())

    def test_invalid_ignore_and_ledger_preflight(self):
        self.install("--project", self.project)
        gi = self.project / ".gitignore"
        old = gi.read_text()
        gi.write_text(old.replace("# dotagents:end skills", ""))
        before = self.snapshot()
        r = self.uninstall("--project", self.project, ok=False)
        self.assertIn("LỖI:", r.stderr)
        self.assertEqual(before, self.snapshot())
        gi.write_text(old)
        state = self.project / ".dotagents-state.json"
        state.write_text('{"version": 99, "agents": {}}')
        before = self.snapshot()
        r = self.uninstall("--project", self.project, ok=False)
        self.assertIn("LỖI:", r.stderr)
        self.assertEqual(before, self.snapshot())

    def test_leaf_symlink_unlinked_without_touching_outside(self):
        self.install("--project", self.project, "--codex")
        skill = self.project / ".codex/skills/brainstorming"
        import shutil
        shutil.rmtree(skill)
        outside = self.base / "outside"
        outside.mkdir()
        (outside / "private.txt").write_text("keep outside")
        skill.symlink_to(outside, target_is_directory=True)
        self.uninstall("--project", self.project, "--codex")
        self.assertEqual((outside / "private.txt").read_text(), "keep outside")
        self.uninstall("--restore", self.backup())
        self.assertTrue(skill.is_symlink())

    def test_user_toml_comments_are_preserved(self):
        self.install("--codex")
        p = Path(self.env["CODEX_HOME"]) / "config.toml"
        p.write_text(p.read_text().replace("multi_agent = true", "multi_agent = true # user note"))
        self.uninstall("--codex")
        self.assertIn("# user note", p.read_text())

    def test_interrupted_uninstall_can_restore(self):
        sys.path.insert(0, str(KIT / "scripts"))
        import dotagents_lifecycle as lifecycle
        root = self.base / "partial"
        root.mkdir()
        a, b = root / "a.txt", root / "b.txt"
        a.write_text("a")
        b.write_text("b")
        plan = lifecycle.RemovalPlan()
        plan.roots.add(root)
        plan.change(a)
        plan.change(b)
        real_remove = lifecycle.remove

        def interrupted(path):
            if path == b:
                raise OSError("simulated disk failure")
            real_remove(path)

        with mock.patch.object(lifecycle, "remove", side_effect=interrupted):
            with self.assertRaises(OSError):
                lifecycle.apply_plan(plan, self.backups)
        self.assertFalse(a.exists())
        self.assertTrue(b.exists())
        lifecycle.restore(self.backup(), False)
        self.assertEqual(a.read_text(), "a")
        self.assertEqual(b.read_text(), "b")

    def test_plan_refuses_target_changed_after_preflight(self):
        sys.path.insert(0, str(KIT / "scripts"))
        import dotagents_lifecycle as lifecycle
        p = self.project / "changed.txt"
        p.write_text("original")
        plan = lifecycle.RemovalPlan()
        plan.roots.add(self.project)
        plan.change(p)
        p.write_text("user edit")
        before = self.snapshot()
        with self.assertRaises(ValueError):
            lifecycle.apply_plan(plan, self.backups)
        self.assertEqual(before, self.snapshot())

    def test_gitfile_project_ignore(self):
        git = self.project / ".git"
        original_git = self.base / "project-git"
        git.rename(original_git)
        git.write_text("gitdir: " + str(original_git) + "\n")
        self.install("--project", self.project, "--codex")
        self.assertIn(".codex/skills/brainstorming/", (self.project / ".gitignore").read_text())
        self.uninstall("--project", self.project, "--codex")
        self.assertNotIn("dotagents:begin skills", (self.project / ".gitignore").read_text())
        self.assertTrue(git.exists())

    def test_json_user_config_and_preexisting_playwright(self):
        root = Path(self.env["CLAUDE_CONFIG_DIR"])
        root.mkdir()
        mcp = {"mcpServers": {"playwright": {"command": "my-server"}}}
        (root / ".claude.json").write_text(json.dumps(mcp))
        self.install("--claude")
        settings = root / "settings.json"
        data = json.loads(settings.read_text())
        data["includeCoAuthoredBy"] = True
        data["private"] = {"keep": 1}
        settings.write_text(json.dumps(data))
        self.uninstall("--claude")
        self.assertEqual(json.loads((root / ".claude.json").read_text()), mcp)
        self.assertEqual(json.loads(settings.read_text())["private"], {"keep": 1})
        self.assertTrue(json.loads(settings.read_text())["includeCoAuthoredBy"])

    def test_global_rules_only_and_check(self):
        before = self.snapshot()
        self.uninstall("--all", "--check")
        self.assertEqual(before, self.snapshot())
        self.install("--codex", "--rules-only")
        self.uninstall("--codex", "--rules-only")
        root = Path(self.env["CODEX_HOME"])
        self.assertFalse((root / "AGENTS.md").exists())
        self.assertFalse((root / "config.toml").exists())


if __name__ == "__main__":
    unittest.main(verbosity=2)
