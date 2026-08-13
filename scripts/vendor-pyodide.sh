#!/usr/bin/env bash
# Vendors the Pyodide core + the wheel closure marimo needs at boot into
# vendor/pyodide/, and patches the vendored islands worker chunk to accept
# local overrides (globalThis.__PYODIDE_BASE__ / __MARIMO_LOCK__, injected by
# the plugin's worker shim). After this, notebooks using marimo + stdlib run
# fully offline; additional packages (numpy, …) still resolve from the CDN.
#
# Run scripts/vendor-islands.sh first.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MARIMO_VERSION="$(grep -o 'ISLANDS_VERSION = "[^"]*"' "$ROOT/src/main.ts" | cut -d'"' -f2)"
# Must match the pyodide dependency of @marimo-team/islands (package.json).
PYODIDE_VERSION="v314.0.0"

[[ -d "$ROOT/vendor/islands" ]] || { echo "vendor/islands missing — run scripts/vendor-islands.sh first" >&2; exit 1; }

export ROOT MARIMO_VERSION PYODIDE_VERSION
python3 <<'PY'
import json, os, re, sys, urllib.request
from pathlib import Path

root = Path(os.environ["ROOT"])
marimo_ver = os.environ["MARIMO_VERSION"]
pyodide_ver = os.environ["PYODIDE_VERSION"]

cdn = f"https://cdn.jsdelivr.net/pyodide/{pyodide_ver}/full/"
lock_url = f"https://wasm.marimo.app/pyodide-lock.json?v={marimo_ver}&pyodide={pyodide_ver}"
dest = root / "vendor" / "pyodide" / pyodide_ver / "full"
dest.mkdir(parents=True, exist_ok=True)

UA = {"User-Agent": "Mozilla/5.0 (obsidian-marimo vendor script)"}

def fetch(url: str) -> bytes:
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req) as r:
        return r.read()

def download(url: str, name: str):
    out = dest / name
    if out.exists():
        print(f"  cached  {name}")
        return
    print(f"  fetch   {name}")
    out.write_bytes(fetch(url))

# Pyodide core
for f in ["pyodide.asm.mjs", "pyodide.asm.wasm", "python_stdlib.zip"]:
    download(cdn + f, f)

# marimo's lockfile and the wheel closure marimo needs at boot
lock = json.loads(fetch(lock_url))
packages = lock["packages"]

NEEDED = [
    "micropip", "msgspec", "marimo-base", "markdown", "pymdown-extensions",
    "narwhals", "packaging", "pygments", "docutils", "jedi", "parso",
    "pyodide-http",
]
closure: set[str] = set()
queue = list(NEEDED)
while queue:
    name = queue.pop()
    if name in closure:
        continue
    if name not in packages:
        sys.exit(f"package {name!r} not found in marimo lockfile")
    closure.add(name)
    queue.extend(packages[name]["depends"])

for name in sorted(closure):
    entry = packages[name]
    file_name = entry["file_name"]
    url = file_name if file_name.startswith("http") else cdn + file_name
    base = file_name.rsplit("/", 1)[-1]
    download(url, base)
    entry["file_name"] = base  # resolve against the (local) packageBaseUrl

# Non-vendored packages keep working online: make their URLs absolute.
for name, entry in packages.items():
    if name not in closure and not entry["file_name"].startswith("http"):
        entry["file_name"] = cdn + entry["file_name"]

(root / "vendor" / "pyodide" / "pyodide-lock.json").write_text(json.dumps(lock))
print(f"lockfile rewritten ({len(closure)} vendored, {len(packages) - len(closure)} remote)")

# Patch the worker chunk to honor the override globals.
chunks = list((root / "vendor" / "islands" / "assets").glob("worker-*.js"))
if not chunks:
    sys.exit("no worker chunk found in vendor/islands/assets")
for chunk in chunks:
    src = chunk.read_text()
    if "__PYODIDE_BASE__" in src:
        print(f"already patched {chunk.name}")
        continue
    n1 = src.count("https://cdn.jsdelivr.net/pyodide/")
    src = src.replace(
        "https://cdn.jsdelivr.net/pyodide/",
        '${globalThis.__PYODIDE_BASE__||"https://cdn.jsdelivr.net/pyodide/"}',
    )
    n2 = src.count("https://wasm.marimo.app/pyodide-lock.json")
    src = src.replace(
        "https://wasm.marimo.app/pyodide-lock.json",
        '${globalThis.__MARIMO_LOCK__||"https://wasm.marimo.app/pyodide-lock.json"}',
    )
    if n1 == 0 or n2 == 0:
        sys.exit(f"expected literals not found in {chunk.name} (cdn={n1}, lock={n2})")
    chunk.write_text(src)
    print(f"patched {chunk.name} (cdn x{n1}, lock x{n2})")

size = sum(f.stat().st_size for f in dest.iterdir()) / 1e6
print(f"vendored pyodide → vendor/pyodide ({size:.0f} MB)")
PY
