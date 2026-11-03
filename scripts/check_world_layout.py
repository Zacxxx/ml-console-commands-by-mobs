#!/usr/bin/env python3
"""Read-only check that the world adapter's entry fingerprints match an installed EXE."""
import argparse
from pathlib import Path
import re
import struct


def verify(exe, header):
    data = Path(exe).read_bytes()
    pe = struct.unpack_from('<I', data, 0x3c)[0]
    assert data[pe:pe + 4] == b'PE\0\0', 'Not a PE binary'
    assert struct.unpack_from('<I', data, pe + 8)[0] == 0x6836c1ba, 'Unsupported timestamp'
    assert struct.unpack_from('<I', data, pe + 24 + 56)[0] == 0x9dfd000, 'Unsupported image size'
    sections = []
    count = struct.unpack_from('<H', data, pe + 6)[0]
    optional = struct.unpack_from('<H', data, pe + 20)[0]
    for index in range(count):
        at = pe + 24 + optional + index * 40
        size, rva, raw_size, offset = struct.unpack_from('<IIII', data, at + 8)
        sections.append((rva, raw_size, offset))
    signatures = re.findall(r'\{0x([a-f0-9]+), \{([^}]+)\}\}', Path(header).read_text())
    assert len(signatures) >= 20, 'Incomplete world signatures'
    for rva, fingerprint in signatures:
        rva = int(rva, 16)
        expected = bytes(int(value, 16) for value in fingerprint.split(','))
        section = next((s for s in sections if s[0] <= rva < s[0] + s[1]), None)
        assert section, f'Unmapped native entry {rva:x}'
        at = section[2] + rva - section[0]
        assert data[at:at + len(expected)] == expected, f'Entry changed at {rva:x}'
    return len(signatures)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('exe')
    args = parser.parse_args()
    header = Path(__file__).resolve().parents[1] / 'src/mobs_console/Native/world_layout.h'
    print(f'{verify(args.exe, header)} world native entries match. No game state changed.')
