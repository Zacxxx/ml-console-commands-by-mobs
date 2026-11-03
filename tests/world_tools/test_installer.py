import importlib.util
from pathlib import Path
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location('installer', ROOT / 'scripts/install_local.py')
installer = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(installer)


class InstallerTests(unittest.TestCase):
    def test_preserves_state_user_commands_and_previous_native_libraries(self):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder)
            win64 = base / 'Win64'
            target = win64 / 'ue4ss/Mods/MLConsoleCommandsByMobs'
            for subdir in ['Native/State', 'Commands', 'Scripts']:
                (target / subdir).mkdir(parents=True, exist_ok=True)
            (target / 'Native/State/perks.txt').write_text('user state')
            (target / 'Native/old.dll').write_bytes(b'old adapter')
            (target / 'Commands/example.txt').write_text('my own commands')
            (target / 'Scripts/main.lua').write_text('old main')
            package = base / 'package.zip'
            with zipfile.ZipFile(package, 'w') as archive:
                for name, content in [('Scripts/main.lua', 'new main'), ('Native/world_bridge_name.txt', 'new.dll'),
                                      ('Native/new.dll', 'new adapter'), ('Commands/example.txt', 'sample')]:
                    archive.writestr('MLConsoleCommandsByMobs/' + name, content)
            receipt = installer.install(package, win64, base / 'backup')
            self.assertEqual((target / 'Native/State/perks.txt').read_text(), 'user state')
            self.assertEqual((target / 'Commands/example.txt').read_text(), 'my own commands')
            self.assertEqual((target / 'Native/old.dll').read_bytes(), b'old adapter')
            self.assertEqual((target / 'Scripts/main.lua').read_text(), 'new main')
            self.assertEqual((base / 'backup/Scripts/main.lua').read_text(), 'old main')
            self.assertEqual(receipt['custom_commands_preserved'], ['Commands/example.txt'])
            self.assertEqual(len(receipt['files_verified']), 3)

    def test_rejects_archive_traversal_before_creating_backup(self):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder)
            (base / 'Win64/ue4ss/Mods').mkdir(parents=True)
            with zipfile.ZipFile(base / 'bad.zip', 'w') as archive:
                archive.writestr('MLConsoleCommandsByMobs/../../escape', 'bad')
            with self.assertRaisesRegex(AssertionError, 'Unsafe archive'):
                installer.install(base / 'bad.zip', base / 'Win64', base / 'backup')
            self.assertFalse((base / 'backup').exists())


if __name__ == '__main__':
    unittest.main()
