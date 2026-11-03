#!/usr/bin/env python3
"""Install a Mobs package with a full backup, preserving state and custom command files."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path, PurePosixPath
import os
import shutil
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
MOD = 'MLConsoleCommandsByMobs'


def install(archive_path, win64, backup_directory):
    archive_path = Path(archive_path).resolve()
    win64 = Path(win64).resolve()
    target = win64 / 'ue4ss/Mods' / MOD
    assert (win64 / 'ue4ss/Mods').is_dir(), 'Choose the game Win64 folder containing an installed UE4SS Mods folder'
    files = {}
    with zipfile.ZipFile(archive_path) as archive:
        for entry in archive.infolist():
            path = PurePosixPath(entry.filename)
            assert not path.is_absolute() and '..' not in path.parts and '\\' not in entry.filename, 'Unsafe archive path'
            if len(path.parts) < 2 or path.parts[0] != MOD or entry.is_dir():
                continue
            relative = Path(*path.parts[1:])
            assert relative.parts[0] in {'Scripts', 'Native', 'Commands', 'enabled.txt'}, 'Unexpected mod content'
            assert entry.file_size < 16 * 1024 * 1024, 'Oversized mod entry'
            assert relative.as_posix() not in files, 'Duplicate mod entry'
            files[relative.as_posix()] = archive.read(entry)
    assert 'Scripts/main.lua' in files and 'Native/world_bridge_name.txt' in files, 'Incomplete Mobs package'
    # Validate all destinations before creating a backup or writing the first file.
    for relative in files:
        destination = target / relative
        assert destination.resolve().is_relative_to(target.resolve()), 'Mod destination escapes its folder'
        assert not destination.is_symlink(), 'Managed mod file must not be a symlink'
    backup = Path(backup_directory).resolve()
    assert not backup.exists(), 'Backup directory already exists'
    if target.exists():
        shutil.copytree(target, backup)
    else:
        backup.mkdir(parents=True)
    hashes, preserved = {}, []
    # Put dependencies in place before Lua; write main.lua last.
    order = sorted(files, key=lambda p: (p == 'Scripts/main.lua', p.startswith('Scripts/'), p))
    for relative in order:
        destination = target / relative
        content = files[relative]
        if relative.startswith('Commands/') and destination.exists() and destination.read_bytes() != content:
            preserved.append(relative)
            continue
        destination.parent.mkdir(parents=True, exist_ok=True)
        descriptor, temporary = tempfile.mkstemp(prefix='.mobs-install-', dir=destination.parent)
        try:
            with os.fdopen(descriptor, 'wb') as stream:
                stream.write(content)
            os.replace(temporary, destination)
        finally:
            if os.path.exists(temporary):
                os.unlink(temporary)
        assert destination.read_bytes() == content, f'Install verification failed: {relative}'
        hashes[relative] = hashlib.sha256(content).hexdigest()
    return {
        'installed_at': datetime.now(timezone.utc).isoformat(),
        'archive': str(archive_path),
        'archive_sha256': hashlib.sha256(archive_path.read_bytes()).hexdigest(),
        'target': str(target), 'backup': str(backup),
        'files_verified': hashes, 'custom_commands_preserved': preserved,
        'gameplay_tested': False,
    }


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--archive', type=Path, default=ROOT / 'artifacts/ML-Console-Commands-by-Mobs-0.14.0-alpha.1.zip')
    parser.add_argument('--win64', type=Path, required=True)
    parser.add_argument('--backup', type=Path)
    parser.add_argument('--receipt', type=Path, default=ROOT / 'private/completion-pass-install.json')
    args = parser.parse_args()
    stamp = datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    backup = args.backup or ROOT / ('private/installed-before-completion-pass-' + stamp)
    receipt = install(args.archive, args.win64, backup)
    args.receipt.parent.mkdir(parents=True, exist_ok=True)
    args.receipt.write_text(json.dumps(receipt, indent=4) + '\n')
    print(f"Installed and byte-verified {len(receipt['files_verified'])} files. Backup: {receipt['backup']}")
    print('Custom command files preserved: ' + str(len(receipt['custom_commands_preserved'])))
    print('Receipt: ' + str(args.receipt))
