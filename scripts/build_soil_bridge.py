#!/usr/bin/env python3
"""Build the original exact-build soil adapter."""
from pathlib import Path
import hashlib
import shutil
import subprocess
root = Path(__file__).resolve().parents[1]
native = root / 'src/mobs_console/Native'
source = native / 'soil_bridge.c'
compiler = shutil.which('x86_64-w64-mingw32-gcc')
if not compiler:
    raise SystemExit('MinGW GCC is required to rebuild the soil adapter.')
name = 'mobs_soil_' + hashlib.sha256(source.read_bytes() + (native / 'soil_cells.h').read_bytes()).hexdigest()[:12] + '.dll'
subprocess.run([compiler, '-shared', '-O2', '-Wall', '-Wextra', '-Werror', '-static-libgcc',
                '-o', str(native / name), str(source)], check=True)
(native / 'soil_bridge_name.txt').write_text(name + '\n')
print(name)
