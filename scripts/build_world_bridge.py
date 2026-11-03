#!/usr/bin/env python3
"""Build the original exact-build world adapter."""
from pathlib import Path
import hashlib
import shutil
import subprocess
root = Path(__file__).resolve().parents[1]
native = root / 'src/mobs_console/Native'
source = native / 'world_bridge.c'
compiler = shutil.which('x86_64-w64-mingw32-gcc')
if not compiler:
    raise SystemExit('MinGW GCC is required to rebuild the world adapter.')
name = 'mobs_world_' + hashlib.sha256(source.read_bytes() + (native / 'world_layout.h').read_bytes() + (native / 'world_plan.h').read_bytes()).hexdigest()[:12] + '.dll'
subprocess.run([compiler, '-shared', '-O2', '-Wall', '-Wextra', '-Werror', '-static-libgcc',
                '-o', str(native / name), str(source)], check=True)
(native / 'world_bridge_name.txt').write_text(name + '\n')
print(name)
