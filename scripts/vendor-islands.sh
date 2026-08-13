#!/usr/bin/env bash
# Downloads the @marimo-team/islands dist (version pinned in src/main.ts) into
# vendor/islands/ so the plugin can load the runtime locally instead of from
# jsDelivr. Pyodide itself and Python wheels are still fetched by the runtime
# at notebook boot.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(grep -o 'ISLANDS_VERSION = "[^"]*"' "$ROOT/src/main.ts" | cut -d'"' -f2)"
[[ -n "$VERSION" ]] || { echo "Could not read ISLANDS_VERSION from src/main.ts" >&2; exit 1; }

if [[ -f "$ROOT/vendor/islands/.version" ]] &&
	[[ "$(cat "$ROOT/vendor/islands/.version")" == "$VERSION" ]]; then
	echo "vendor/islands already at $VERSION"
	exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Fetching @marimo-team/islands@${VERSION}..."
(cd "$TMP" && npm pack "@marimo-team/islands@$VERSION" --silent >/dev/null)
tar xzf "$TMP"/*.tgz -C "$TMP"

rm -rf "$ROOT/vendor/islands"
mkdir -p "$ROOT/vendor"
mv "$TMP/package/dist" "$ROOT/vendor/islands"
echo "$VERSION" > "$ROOT/vendor/islands/.version"
echo "Vendored islands $VERSION → vendor/islands ($(du -sh "$ROOT/vendor/islands" | cut -f1))"
