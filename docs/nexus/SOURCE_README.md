# ML Console Commands by Mobs — source release

Independent Lua/UE4SS command implementation and original exact-build native helpers.
See LICENSE (MIT). Original third-party binaries, game assets, saves and private
research are excluded. This source archive is not the playable mod download.

## Build

Work from this archive's root. You need Python 3, Lua 5.4/luac, a C compiler for tests,
and x86_64-w64-mingw32-gcc for the Windows helpers. Pillow is needed only to export
the approved promotional cover and header with scripts/create_nexus_cover.py.

Run each adapter build script:

    python3 scripts/build_forestry_bridge.py
    python3 scripts/build_perks_bridge.py
    python3 scripts/build_soil_bridge.py
    python3 scripts/build_world_bridge.py
    python3 scripts/build_ux_bridge.py

Then run:

    ./scripts/test.sh
    python3 scripts/prepare_nexus.py --out ./release

Native helper filenames derive from their source/header hashes. The manifests select
one library for each helper. The public runtime archive includes exactly those five
libraries. The native adapters target the verified 0.8.117 executable only; changing
version strings is not a compatibility port. Review the native layout and signatures
before adapting to another game executable.

The tests mock the engine for command behavior and test portable native planning/data
structures. They do not prove gameplay, native dropdown rendering or save persistence.
A loaded-settlement integration check is still required for those behaviors.

The generated upload kit includes a clean runtime ZIP and a separate source ZIP,
English Nexus text, a French upload guide, promotional fan artwork and checksums.
It does not publish or upload anything automatically.
