"""Behavioral coverage for the English learning state helper."""
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "skills/ch-learn-english/scripts/english_state.py"


class StateTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / "state"
        spec = importlib.util.spec_from_file_location("english_state", SCRIPT)
        self.assertTrue(SCRIPT.exists(), "English state helper must exist")
        self.mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(self.mod)
        self.store = self.mod.Store(self.root)

    def event(self, prompt, session="chat-A"):
        return self.mod.handle_hook({"session_id": session, "prompt": prompt}, self.store)

    def test_unused_chat_does_not_create_state_and_explicitly_stays_off(self):
        self.assertIn("OFF", self.event("Please explain caching")["hookSpecificOutput"]["additionalContext"])
        self.assertFalse(self.root.exists())

    def test_on_off_status_and_isolation(self):
        self.assertIn("additionalContext", self.event("$ch-learn-english on")["hookSpecificOutput"])
        self.assertTrue(self.store.status("chat-A")["enabled"])
        self.assertFalse(self.store.status("chat-B")["enabled"])
        self.event("$ch-learn-english status")
        self.assertTrue(self.store.status("chat-A")["enabled"])
        self.assertIn("English learning", self.event("Ordinary work")["hookSpecificOutput"]["additionalContext"])
        self.event("$ch-learn-english off")
        self.assertFalse(self.store.status("chat-A")["enabled"])
        self.assertIn("Vietnamese", self.event("Ordinary work")["hookSpecificOutput"]["additionalContext"])

    def test_bare_skill_and_bad_arguments_do_not_enable(self):
        self.event("$ch-learn-english")
        self.event("$ch-learn-english maybe")
        self.assertFalse(self.store.status("chat-A")["enabled"])

    def test_quoted_mention_does_not_change_state(self):
        self.event("Explain what '$ch-learn-english on' means")
        self.assertFalse(self.store.status("chat-A")["enabled"])

    def test_git_sync_controls_preserve_language_mode(self):
        for enabled in (False, True):
            self.store.set_session("chat-A", enabled)
            for prompt in ("$ch-learn-english sync", "$ch-learn-english sync --push"):
                context = self.event(prompt)["hookSpecificOutput"]["additionalContext"]
                self.assertNotIn("Invalid argument", context)
                self.assertIn("Git profile synchronization", context)
                self.assertEqual(self.store.status("chat-A")["enabled"], enabled)

    def test_dictionary_shared_and_forms_independent_from_phrases(self):
        self.store.learn("words", "Asset", forms=["assets"])
        self.store.learn("grammar", "second-conditional", label="Câu điều kiện loại 2", pattern="If + past, would + verb")
        result = self.store.lookup("words", ["asset", "ASSETS", "carry"])
        self.assertEqual(result, {"asset": True, "ASSETS": True, "carry": False})
        self.assertEqual(self.store.lookup("phrases", ["carry out"]), {"carry out": False})
        self.event("$ch-learn-english on", "chat-B")
        context = self.event("Ordinary work", "chat-B")["hookSpecificOutput"]["additionalContext"]
        self.assertIn("asset", context)
        self.assertIn("second-conditional", context)

    def test_learn_forget_and_off_preserve_knowledge(self):
        self.store.learn("phrases", " carry  out ")
        self.assertTrue(self.store.lookup("phrases", ["carry out"])["carry out"])
        self.event("$ch-learn-english off")
        self.assertTrue(self.store.lookup("phrases", ["carry out"])["carry out"])
        self.store.forget("phrases", "carry out")
        self.assertFalse(self.store.lookup("phrases", ["carry out"])["carry out"])

    def test_invalid_session_does_not_escape_root(self):
        for name in ("../escape", "", "/tmp/escape", "a/b"):
            with self.assertRaises(ValueError):
                self.store.set_session(name, True)

    def test_corrupt_knowledge_is_not_reset(self):
        self.store.learn("words", "asset")
        path = self.root / "knowledge.json"
        path.write_text("broken")
        with self.assertRaises(ValueError):
            self.store.learn("words", "cache")
        self.assertEqual(path.read_text(), "broken")

    def test_malformed_schema_is_not_silently_accepted(self):
        self.store.learn("words", "asset")
        (self.root / "knowledge.json").write_text(json.dumps({"version": 1, "words": [], "phrases": {}, "grammar": {}}))
        with self.assertRaises(ValueError):
            self.store.lookup("words", ["asset"])

    def test_symlink_is_rejected(self):
        self.root.mkdir()
        outside = Path(self.temp.name) / "outside.json"
        outside.write_text("private")
        (self.root / "knowledge.json").symlink_to(outside)
        with self.assertRaises(ValueError):
            self.store.learn("words", "asset")
        self.assertEqual(outside.read_text(), "private")

    def test_large_dictionary_uses_lookup_without_losing_data(self):
        for i in range(90):
            self.store.learn("words", "term" + str(i), forms=["term" + str(i) + "s"], label="x" * 120)
        self.event("$ch-learn-english on")
        context = self.event("Ordinary work")["hookSpecificOutput"]["additionalContext"]
        self.assertIn("lookup", context)
        self.assertLess(len(context), 14000)
        self.assertTrue(self.store.lookup("words", ["term89s"])["term89s"])

    def test_concurrent_updates_are_not_lost(self):
        env = dict(os.environ, DOTAGENTS_ENGLISH_STATE_DIR=str(self.root))
        processes = [subprocess.Popen(["python3", str(SCRIPT), "learn", "words", "word" + str(i)], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE) for i in range(12)]
        for process in processes:
            out, err = process.communicate(timeout=20)
            self.assertEqual(process.returncode, 0, err.decode())
        self.assertEqual(len(self.store.knowledge()["words"]), 12)
        self.assertEqual((self.root / "knowledge.json").stat().st_mode & 0o777, 0o600)

    def test_hook_cli_reports_errors_without_false_success(self):
        env = dict(os.environ, DOTAGENTS_ENGLISH_STATE_DIR=str(self.root))
        result = subprocess.run(["python3", str(SCRIPT), "hook"], input='{"session_id":"../bad","prompt":"$ch-learn-english on"}', text=True, capture_output=True, env=env)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("error", result.stderr.lower())

    def test_duplicate_json_keys_preserve_corrupt_file(self):
        self.store.learn("words", "asset")
        path = self.root / "knowledge.json"
        original = '{"version":1,"words":{"asset":{},"asset":{"forms":["assets"]}},"phrases":{},"grammar":{}}'
        path.write_text(original)
        with self.assertRaises(ValueError):
            self.store.learn("words", "cache")
        self.assertEqual(path.read_text(), original)

    def test_long_grammar_labels_and_pattern_lookup(self):
        for length in (500, 501, 1000):
            term = "grammar-" + str(length)
            self.store.learn("grammar", term, label="a" * length, pattern="If + past, would + verb " + str(length))
            self.assertTrue(self.store.lookup("grammar", [term])[term])
            label = "a" * length
            self.assertTrue(self.store.lookup("grammar", [label])[label])
        pattern = "If + past, would + verb 501"
        self.assertTrue(self.store.lookup("grammar", [pattern])[pattern])
        result = self.store.catalog("grammar", offset=0, limit=2)
        self.assertEqual(result["total"], 3)
        self.assertEqual(result["next_offset"], 2)
        self.assertIn("pattern", next(iter(result["entries"].values())))
        self.assertIsNone(self.store.catalog("grammar", offset=2, limit=2)["next_offset"])

    def test_same_turn_context_is_not_duplicated_by_two_hook_scopes(self):
        payload = {"session_id": "chat-A", "turn_id": "turn-1", "prompt": "$ch-learn-english on"}
        first = self.mod.handle_hook(payload, self.store)
        second = self.mod.handle_hook(payload, self.store)
        self.assertIn("hookSpecificOutput", first)
        self.assertEqual(second, {})
        payload["turn_id"] = "turn-2"
        payload["prompt"] = "Ordinary work"
        self.assertIn("hookSpecificOutput", self.mod.handle_hook(payload, self.store))

    def test_concurrent_hook_layers_emit_one_enabled_context(self):
        env = dict(os.environ, DOTAGENTS_ENGLISH_STATE_DIR=str(self.root))
        payload = json.dumps({"session_id": "chat-A", "turn_id": "turn-1", "prompt": "$ch-learn-english on"})
        processes = [subprocess.Popen(["python3", str(SCRIPT), "hook"], env=env, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True) for _ in range(2)]
        for process in processes:
            process.stdin.write(payload)
            process.stdin.close()
            process.stdin = None
        outputs = []
        for process in processes:
            out, err = process.communicate(timeout=20)
            self.assertEqual(process.returncode, 0, err)
            outputs.append(json.loads(out))
        self.assertEqual(sum("hookSpecificOutput" in out for out in outputs), 1)

    def test_delayed_duplicate_does_not_repeat_control_or_context(self):
        first = {"session_id": "chat-A", "turn_id": "turn-1", "prompt": "$ch-learn-english on"}
        self.mod.handle_hook(first, self.store)
        self.mod.handle_hook({"session_id": "chat-A", "turn_id": "turn-2", "prompt": "$ch-learn-english off"}, self.store)
        self.assertEqual(self.mod.handle_hook(first, self.store), {})
        self.assertFalse(self.store.status("chat-A")["enabled"])

    def test_invalid_grammar_metadata_rejected_at_write_and_read(self):
        for invalid in ("   ", "", "bad\x01metadata"):
            for key in ("label", "pattern"):
                with self.assertRaises(ValueError):
                    self.store.learn("grammar", "known", **{key: invalid})
        self.store.learn("grammar", "known", label="valid")
        path = self.root / "knowledge.json"
        data = json.loads(path.read_text())
        data["grammar"]["known"]["label"] = "   "
        path.write_text(json.dumps(data))
        with self.assertRaises(ValueError):
            self.store.knowledge()

    def test_catalog_revision_prevents_skipping_after_concurrent_removal(self):
        for term in ("a", "b", "c"):
            self.store.learn("grammar", term)
        page = self.store.catalog("grammar", limit=2)
        self.store.forget("grammar", "a")
        with self.assertRaises(ValueError):
            self.store.catalog("grammar", offset=page["next_offset"], limit=2, revision=page["revision"])


if __name__ == "__main__":
    unittest.main()
