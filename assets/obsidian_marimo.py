"""Access the Obsidian vault from marimo notebooks.

Provided by the obsidian-marimo plugin. Usage:

    from obsidian_marimo import vault

    text = await vault.read("some note.md")
    files = await vault.files()
"""

import json

import js
from pyodide.http import pyfetch

VAULT_INDEX = ".obsidian/plugins/marimo/vault-index.json"


class Vault:
    """Reads files from the vault this notebook lives in."""

    def __init__(self) -> None:
        #: The vault root as an app:// URL.
        self.base: str = str(js.__VAULT_BASE__)

    async def read(self, path: str) -> str:
        """Return the current text content of a vault file."""
        resp = await pyfetch(f"{self.base}{path}?t={js.Date.now()}")
        return await resp.string()

    async def files(self) -> list:
        """Live index of the vault's markdown files (path, size, mtime)."""
        return json.loads(await self.read(VAULT_INDEX))


vault = Vault()
