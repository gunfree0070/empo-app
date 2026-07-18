# Config format — JSON5 shared subset

Empo reads developer-authored config files in two runtimes:

| Runtime | Implementation | Typical files |
|---------|----------------|---------------|
| iOS host | `JSON5LiteParser.swift` | `gameRegistry.json`, bundled `Patches/*/patches.json`, JGP sidecars at import |
| Engine | `json5pp.hpp` (full JSON5) | `mkxp.json`, `patches.json` in `EmpoState/` |

These are intentionally separate parsers (Swift vs C++). This document defines the
**shared subset** both sides must agree on for files the host writes and the engine
reads (notably merged `EmpoState/patches.json` and fields copied into managed config).

## Supported (host + engine must match)

- Standard JSON objects, arrays, strings, numbers, booleans, `null`
- `//` line comments outside string literals
- UTF-8 encoding
- LF, CRLF, or CR line endings (host normalizes to LF before parsing)

## Host-only (`JSON5LiteParser`)

The Swift parser is deliberately minimal:

- **No** `/* */` block comments
- **No** trailing commas
- **No** single-quoted strings
- **No** unquoted keys

If a curator adds block comments to a bundled JSON file the host loads, move the
comment to a `//` line or strip it before commit.

## Engine-only (`json5pp`)

The engine accepts the full JSON5 feature set for `mkxp.json` and game-authored
configs: block comments, trailing commas, hex numbers, unquoted keys, etc.

Do not rely on engine-only features in host-generated files under `EmpoState/`.

## String safety

Both parsers must preserve `//` sequences **inside** double-quoted strings (e.g.
URLs). The host implements a small state machine for this; engine json5pp handles
it as part of full JSON5 string rules.

## When to extend

If import-time parsing disagrees with engine runtime parsing for the same file:

1. Add a fixture to `GameProbeTests` for the failing bytes.
2. Update this doc and either widen `JSON5LiteParser` or simplify the authored file.
3. Prefer keeping host output strict JSON-with-`//`-comments.

## Session flags outside mkxp.json

Network access is **not** an `mkxp.json` key: it is a per-boot host bridge
flag (`MKXPSessionConfig.networkEnabled`, from the per-game "Network access"
setting, default on). Game scripts and patches can branch on it via
`System.network_enabled?` — when false, the game sees the equivalent of
airplane mode: network libraries load and their classes exist, but the
native client refuses requests, socket connects raise `Errno::ENETDOWN`,
and downloads report failure, so games take the same offline fallback
paths they ship for desktop players without internet. (Postload stubs for
Windows-only online modules still apply while offline.) The TLS trust
store is host-provided (`mkxp_setCABundlePath`, exported to Ruby as
`SSL_CERT_FILE`) and silently refreshed by the launcher.

## References

- `ios/Empo/src/Library/JSON5LiteParser.swift`
- `mkxp-z-apple-mobile/src/util/json5pp.hpp`
- `mkxp-z-apple-mobile/src/config.cpp`, `patcher.cpp`
