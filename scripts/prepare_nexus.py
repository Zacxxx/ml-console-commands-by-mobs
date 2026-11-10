#!/usr/bin/env python3
"""Prepare a clean, reproducible Nexus upload kit without uploading anything."""
import argparse
import csv
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import re
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[1]
MOD = 'MLConsoleCommandsByMobs'
VERSION = re.search(r'local VERSION = "([^"]+)"', (ROOT / 'src/mobs_console/Scripts/main.lua').read_text())[1]
TEMPLATES = ROOT / 'docs/nexus'
PUBLIC = json.loads((ROOT / 'config/nexus_release.json').read_text())
BRIDGES = [
    ('bridge_name.txt', 'mobs_forestry_', 'forestry_bridge.c', ['forestry_growth.h']),
    ('perks_bridge_name.txt', 'mobs_perks_', 'perks_bridge.c', ['perk_containers.h']),
    ('soil_bridge_name.txt', 'mobs_soil_', 'soil_bridge.c', ['soil_cells.h']),
    ('world_bridge_name.txt', 'mobs_world_', 'world_bridge.c', ['world_layout.h', 'world_plan.h']),
    ('ux_bridge_name.txt', 'mobs_ux_', 'ux_bridge.c', ['autocomplete_tree.h']),
]


def validate_library(name, prefix):
    if not re.fullmatch(re.escape(prefix) + r'[0-9a-f]{12}\.dll', name):
        raise ValueError('Invalid native manifest: ' + name)
    return name


def native_files():
    folder = ROOT / 'src/mobs_console/Native'
    files = []
    for manifest, prefix, source, headers in BRIDGES:
        name = validate_library((folder / manifest).read_text().strip(), prefix)
        digest = hashlib.sha256(b''.join((folder / part).read_bytes() for part in [source, *headers])).hexdigest()[:12]
        if name != prefix + digest + '.dll':
            raise ValueError('Native source/manifest drift: ' + manifest)
        if (folder / name).read_bytes()[:2] != b'MZ':
            raise ValueError('Not a PE library: ' + name)
        files.extend([(f'{MOD}/Native/{name}', (folder / name).read_bytes()),
                      (f'{MOD}/Native/{manifest}', (name + '\n').encode())])
    return files


def registry():
    process = subprocess.run(['lua', 'scripts/export_command_reference.lua'], cwd=ROOT,
                             check=True, text=True, capture_output=True)
    rows = list(csv.reader(io.StringIO(process.stdout), delimiter='\t'))
    if not rows or any(len(row) != 4 for row in rows):
        raise ValueError('Cannot export the live command registry')
    return [dict(zip(['name', 'category', 'usage', 'description'], row)) for row in rows]


def command_reference(rows):
    lines = ['# Command reference', '', f'Version {VERSION} — {len(rows)} base names/aliases, plus detailed dotted advice shortcuts.', '',
             'Generated from the registered implementation without executing gameplay commands.', '',
             'Use mobs.advice.<command> for detailed guides and mobs.tutorial for the tutorial. Required arguments use <...>;',
             'optional arguments use [...]. Replace the placeholders; do not type their brackets.', '',
             'Preview/undo are available only where explicitly documented. Read KNOWN_ISSUES.md.', '']
    for category in ['lord', 'region', 'army', 'misc']:
        lines += [f'## {category.title()}', '', '| Usage | Behavior |', '| --- | --- |']
        for row in rows:
            if row['category'] == category:
                usage = row['usage'].replace('|', '\\|')
                description = row['description'].replace('|', '\\|')
                lines.append(f'| `{usage}` | {description} |')
        lines.append('')
    return '\n'.join(lines)


def runtime_files(rows=None):
    rows = registry() if rows is None else rows
    files = []
    for folder, suffix in [('Scripts', '*.lua'), ('Commands', '*.txt')]:
        for path in sorted((ROOT / 'src/mobs_console' / folder).glob(suffix)):
            if path.is_symlink():
                raise ValueError('Symlink in release: ' + str(path))
            files.append((f'{MOD}/{folder}/{path.name}', path.read_bytes()))
    files.extend(native_files())
    files.extend([(f'{MOD}/enabled.txt', b''), (f'{MOD}/LICENSE', (ROOT / 'LICENSE').read_bytes()),
                  (f'{MOD}/README.md', (TEMPLATES / 'README_USER.md').read_bytes()),
                  (f'{MOD}/COMMANDS.md', command_reference(rows).encode()),
                  (f'{MOD}/TUTORIAL.md', (ROOT / 'docs/wiki/Tutorial.md').read_bytes()),
                  (f'{MOD}/ITEM_IDS.csv', (ROOT / 'docs/wiki/item_ids.csv').read_bytes())])
    for name in ['KNOWN_ISSUES.md', 'CHANGELOG.md']:
        files.append((f'{MOD}/{name}', (TEMPLATES / name).read_bytes()))
    return files


def source_files():
    readme = (TEMPLATES / 'REPOSITORY_README.md').read_text()
    for key, value in {'VERSION': VERSION, 'COMMAND_COUNT': str(len(registry())),
                       'REPOSITORY_URL': PUBLIC['repository_url'], 'ISSUES_URL': PUBLIC['issues_url'],
                       'RELEASE_URL': PUBLIC['release_url']}.items():
        readme = readme.replace('{{' + key + '}}', value)
    files = [('README.md', readme.encode()),
             ('.gitignore', (TEMPLATES / 'SOURCE.gitignore').read_bytes()),
             ('LICENSE', (ROOT / 'LICENSE').read_bytes())]
    for folder, pattern in [('src/mobs_console/Scripts', '*.lua'), ('src/mobs_console/Commands', '*.txt'),
                            ('src/mobs_console/Native', '*.c'), ('src/mobs_console/Native', '*.h'),
                            ('src/mobs_console/Native', '*name.txt'), ('config', '*.json'),
                            ('docs/nexus', '*'), ('assets/nexus', '*.png')]:
        for path in sorted((ROOT / folder).glob(pattern)):
            if path.is_file() and not path.is_symlink():
                files.append((path.relative_to(ROOT).as_posix(), path.read_bytes()))
    for name in ['prepare_nexus.py', 'export_command_reference.lua', 'create_nexus_cover.py',
                 'build_forestry_bridge.py', 'build_perks_bridge.py', 'build_soil_bridge.py',
                 'build_world_bridge.py', 'build_ux_bridge.py', 'command_parity.py',
                 'check_world_layout.py', 'install_local.py', 'build_guidance.py', 'build_wiki.py']:
        files.append(('scripts/' + name, (ROOT / 'scripts' / name).read_bytes()))
    runner = (ROOT / 'scripts/test.sh').read_text()
    runner = '\n'.join(line for line in runner.splitlines() if 'tests/patch_archive' not in line) + '\n'
    files.append(('scripts/test.sh', runner.encode()))
    for path in sorted((ROOT / 'tests').rglob('*')):
        if path.is_file() and path.suffix in {'.py', '.lua', '.c'} and 'patch_archive' not in path.parts:
            files.append((path.relative_to(ROOT).as_posix(), path.read_bytes()))
    files.append(('docs/command_parity.md', (ROOT / 'docs/command_parity.md').read_bytes()))
    for name, template in [('BUILD.md', 'SOURCE_README.md'), ('INSTALL.md', 'README_USER.md'),
                           ('KNOWN_ISSUES.md', 'KNOWN_ISSUES.md')]:
        files.append(('docs/' + name, (TEMPLATES / template).read_bytes()))
    files.append(('docs/COMMANDS.md', command_reference(registry()).encode()))
    files.append(('CHANGELOG.md', (TEMPLATES / 'CHANGELOG.md').read_bytes()))
    for path in sorted((ROOT / 'docs/wiki').glob('*')):
        if path.is_file() and path.suffix in {'.md', '.csv'}:
            files.append((path.relative_to(ROOT).as_posix(), path.read_bytes()))
    for path in sorted((ROOT / '.github').rglob('*')):
        if path.is_file() and not path.is_symlink():
            files.append((path.relative_to(ROOT).as_posix(), path.read_bytes()))
    return files


def write_archive(path, files):
    names = set()
    for name, _ in files:
        relative = PurePosixPath(name)
        if relative.is_absolute() or '..' in relative.parts or '\\' in name or name in names:
            raise ValueError('Unsafe or duplicate archive member: ' + name)
        names.add(name)
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + '.tmp')
    try:
        with zipfile.ZipFile(temporary, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
            for name, content in sorted(files):
                info = zipfile.ZipInfo(name, (1980, 1, 1, 0, 0, 0))
                info.compress_type = zipfile.ZIP_DEFLATED
                executable = name.startswith('scripts/') and name.endswith(('.sh', '.py'))
                info.external_attr = (0o100755 if executable else 0o100644) << 16
                info.create_system = 3
                archive.writestr(info, content)
        with zipfile.ZipFile(temporary) as archive:
            if archive.testzip() is not None:
                raise ValueError('Archive integrity check failed')
        temporary.replace(path)
    finally:
        temporary.unlink(missing_ok=True)


def bbcode(markdown):
    value = re.sub(r'\[([^\]]+)\]\((https?://[^)]+)\)', r'[url=\2]\1[/url]', markdown)
    value = re.sub(r'\*\*(.+?)\*\*', r'[b]\1[/b]', value)
    value = re.sub(r'`([^`]+)`', r'[font=Courier New]\1[/font]', value)
    value = re.sub(r'^#{1,2} (.+)$', r'[size=5][b]\1[/b][/size]', value, flags=re.MULTILINE)
    return value


def prepare(output):
    output.mkdir(parents=True, exist_ok=True)
    rows = registry()
    stem = 'ML-Console-Commands-by-Mobs-' + VERSION
    main_name, source_name = stem + '-Nexus.zip', stem + '-Source.zip'
    main_files = runtime_files(rows)
    write_archive(output / main_name, main_files)
    write_archive(output / source_name, source_files())
    description = (TEMPLATES / 'DESCRIPTION.template.md').read_text().replace('{{VERSION}}', VERSION).replace('{{COMMAND_COUNT}}', str(len(rows)))
    for key, value in {'REPOSITORY_URL': PUBLIC['repository_url'], 'ISSUES_URL': PUBLIC['issues_url'],
                       'RELEASE_URL': PUBLIC['release_url']}.items():
        description = description.replace('{{' + key + '}}', value)
    (output / 'DESCRIPTION.md').write_text(description)
    (output / 'DESCRIPTION_BBCODE.txt').write_text(bbcode(description))
    summary = ('Console tools for construction, Supplies piles, resources, trees, regional perk cards and settlement management. '
               'Searchable help, command suggestions and previews where supported. For Manor Lords 0.8.117 with UE4SS; alpha release.')
    (output / 'SUMMARY.txt').write_text(summary + '\n')
    (output / 'COMMANDS.md').write_text(command_reference(rows))
    (output / 'COMMANDS.json').write_text(json.dumps(rows, ensure_ascii=False, indent=4) + '\n')
    for name in ['UPLOAD_FR.md', 'PERMISSIONS.txt', 'CHANGELOG.md', 'KNOWN_ISSUES.md']:
        shutil.copyfile(TEMPLATES / name, output / name)
    images = output / 'images'
    images.mkdir(exist_ok=True)
    for path in (ROOT / 'assets/nexus').glob('*.png'):
        shutil.copyfile(path, images / path.name)
    fields = {
        'game': 'Manor Lords', 'game_domain': 'manorlords', 'name': 'ML Console Commands by Mobs',
        'repository_url': PUBLIC['repository_url'], 'issues_url': PUBLIC['issues_url'],
        'release_url': PUBLIC['release_url'], 'author_display_name': 'Mobs', 'version': VERSION, 'category': 'Gameplay', 'language': 'English',
        'summary': summary, 'description_file': 'DESCRIPTION_BBCODE.txt',
        'main_file': {'filename': main_name, 'category': 'Main Files', 'version': VERSION,
                      'description': 'Manor Lords 0.8.117 only. UE4SS/ConsoleEnablerMod required separately. Manual install; alpha. Includes runtime and user guide.'},
        'source_file': {'filename': source_name, 'category': 'Miscellaneous Files', 'version': VERSION,
                        'description': 'Original source, tests and build tools (MIT). Not required to play. No original-mod binaries or game assets.'},
        'requirements': [{'name': 'Compatible UE4SS 3.0.1 plus ConsoleEnablerMod',
                          'url': 'https://www.nexusmods.com/manorlords/mods/229',
                          'notes': 'Choose a loader file compatible with 0.8.117; displayed Nexus-page compatibility may differ. Development loader Git SHA e3ba1016.'}],
        'tags_to_apply': ['AI-Generated Content', 'AI Media'],
        'additional_tags_if_available': ['Cheats', 'Utilities', 'Gameplay'],
        'adult_content': False, 'permissions_file': 'PERMISSIONS.txt',
        'cover_image': 'images/cover-1600x900.png',
        'cover_caption': 'Original promotional title card; not a gameplay screenshot. Version 0.14.0-alpha.1 for Manor Lords 0.8.117.',
        'ai_disclosure': 'Generative AI produced code and release copy under Mobs direction; promotional title card drawn with original generated code.',
        'monetization_or_rewards_selected': False, 'uploaded': False, 'published': False,
    }
    (output / 'FIELDS.json').write_text(json.dumps(fields, ensure_ascii=False, indent=4) + '\n')
    report = {
        'version': VERSION, 'game_target': '0.8.117', 'registered_names_including_aliases': len(rows),
        'native_library_count': 5, 'runtime_root': MOD,
        'archives': [main_name, source_name], 'zip_crc_verified': True,
        'reproducible_zip_metadata': True, 'upstream_binaries_included': False,
        'save_files_or_private_state_included': False, 'dependencies_bundled': False,
        'in_game_confirmation': 'Focused user confirmations only: construction, Supplies/piles, regional perks.',
        'remaining_gameplay_confirmation': 'Recent variants and native dropdown/Tab interactions, persistence and broader platform/other-mod combinations.',
        'automated_tests': 'Run scripts/test.sh; attach current evidence locally. Archive CRC/manifest checks run during preparation.',
        'uploaded': False, 'published': False,
        'main_payload_sha256': {name: hashlib.sha256(data).hexdigest() for name, data in sorted(main_files)},
    }
    (output / 'RELEASE_REPORT.json').write_text(json.dumps(report, ensure_ascii=False, indent=4) + '\n')
    checksums = []
    for path in sorted(output.rglob('*')):
        if path.is_file() and path.name != 'CHECKSUMS.sha256':
            checksums.append(hashlib.sha256(path.read_bytes()).hexdigest() + '  ' + path.relative_to(output).as_posix())
    (output / 'CHECKSUMS.sha256').write_text('\n'.join(checksums) + '\n')
    print(f'Prepared {len(rows)} registered command names; 5 native helpers. No upload/publication performed.')
    print(output / main_name)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, default=ROOT / 'artifacts/nexus' / VERSION)
    prepare(parser.parse_args().out.resolve())
