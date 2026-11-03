#!/usr/bin/env python3
"""Build the independent exact-build native console adapter."""
from pathlib import Path
import hashlib
import shutil
import subprocess
root = Path(__file__).resolve().parents[1]
native = root / 'src/mobs_console/Native'
source = native / 'ux_bridge.c'
compiler = shutil.which('x86_64-w64-mingw32-gcc')
if not compiler:
    raise SystemExit('MinGW GCC is required to rebuild the console adapter.')
name = 'mobs_ux_' + hashlib.sha256(source.read_bytes() + (native / 'autocomplete_tree.h').read_bytes()).hexdigest()[:12] + '.dll'
subprocess.run([compiler, '-shared', '-O2', '-Wall', '-Wextra', '-Werror', '-static-libgcc',
                '-o', str(native / name), str(source)], check=True)
(native / 'ux_bridge_name.txt').write_text(name + '\n')
print(name)
