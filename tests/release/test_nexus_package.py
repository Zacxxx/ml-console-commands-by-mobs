import importlib.util
from pathlib import Path
import tempfile
import subprocess
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location('nexus', ROOT / 'scripts/prepare_nexus.py')
nexus = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(nexus)


class NexusPackageTests(unittest.TestCase):
    def test_runtime_has_one_install_root_and_no_private_material(self):
        with tempfile.TemporaryDirectory() as temporary:
            archive = Path(temporary) / 'runtime.zip'
            nexus.write_archive(archive, nexus.runtime_files())
            with zipfile.ZipFile(archive) as package:
                names = package.namelist()
                self.assertTrue(all(name.startswith('MLConsoleCommandsByMobs/') for name in names))
                self.assertIn('MLConsoleCommandsByMobs/enabled.txt', names)
                self.assertIn('MLConsoleCommandsByMobs/Scripts/main.lua', names)
                self.assertEqual(len([name for name in names if name.endswith('.dll')]), 5)
                self.assertFalse(any(name.endswith(('.request', '.response', '.sav', '.py', '.c')) for name in names))
                self.assertFalse(any('/State/' in name or 'private/' in name for name in names))
                self.assertIsNone(package.testzip())

    def test_build_is_reproducible_and_sources_exclude_binaries_and_patch_tool(self):
        files = nexus.source_files()
        names = [name for name, _ in files]
        self.assertNotIn('src/patch_archive.py', names)
        self.assertFalse(any(name.endswith('.dll') or name.startswith('private/') for name in names))
        self.assertIn('src/mobs_console/Native/ux_bridge.c', names)
        self.assertIn('tests/console_ux/test_ux.lua', names)
        with tempfile.TemporaryDirectory() as temporary:
            a, b = Path(temporary) / 'a.zip', Path(temporary) / 'b.zip'
            nexus.write_archive(a, files)
            nexus.write_archive(b, files)
            self.assertEqual(a.read_bytes(), b.read_bytes())

    def test_public_gitignore_keeps_release_tests_tracked(self):
        with tempfile.TemporaryDirectory() as temporary:
            folder = Path(temporary)
            subprocess.run(['git', 'init', '--quiet', str(folder)], check=True)
            (folder / '.gitignore').write_bytes((ROOT / 'docs/nexus/SOURCE.gitignore').read_bytes())
            (folder / 'tests/release').mkdir(parents=True)
            (folder / 'tests/release/test_example.py').write_text('test')
            (folder / 'release').mkdir()
            (folder / 'release/runtime.zip').write_bytes(b'archive')
            check = subprocess.run(['git', 'check-ignore', 'tests/release/test_example.py'], cwd=folder, capture_output=True)
            self.assertEqual(check.returncode, 1, 'Published tests must not be ignored')
            build = subprocess.run(['git', 'check-ignore', 'release/runtime.zip'], cwd=folder, capture_output=True)
            self.assertEqual(build.returncode, 0, 'Generated release outputs should be ignored')

    def test_rejects_traversal_duplicates_and_non_mobs_native_manifests(self):
        with tempfile.TemporaryDirectory() as temporary:
            target = Path(temporary) / 'bad.zip'
            for files in [[('../escape', b'bad')], [('/absolute', b'bad')], [('ok', b'a'), ('ok', b'b')]]:
                with self.assertRaises(ValueError):
                    nexus.write_archive(target, files)
        with self.assertRaises(ValueError):
            nexus.validate_library('../original.dll', 'mobs_ux_')
        with self.assertRaises(ValueError):
            nexus.validate_library('original.dll', 'mobs_ux_')


if __name__ == '__main__':
    unittest.main()
