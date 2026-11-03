#!/usr/bin/env python3
"""Build the original, version-gated native forestry adapter (MinGW GCC)."""
from pathlib import Path
import hashlib
import shutil
import subprocess
root = Path(__file__).resolve().parents[1]
native = root / 'src/mobs_console/Native'
source = native / 'forestry_bridge.c'
compiler = shutil.which('x86_64-w64-mingw32-gcc')
if not compiler:
    raise SystemExit('Install gcc-mingw-w64-x86-64-posix to rebuild the forestry adapter.')
name = 'mobs_forestry_' + hashlib.sha256(source.read_bytes() + (native / 'forestry_growth.h').read_bytes()).hexdigest()[:12] + '.dll'
subprocess.run([compiler, '-shared', '-O2', '-Wall', '-Wextra', '-Werror', '-static-libgcc',
                '-o', str(native / name), str(source)], check=True)
(native / 'bridge_name.txt').write_text(name + '\n')
print(name)
