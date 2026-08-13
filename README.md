# obsidian-marimo

Obsidian plugin to embed and render [marimo](https://marimo.io) notebooks inline in notes.

Current state: hello-world scaffold. A `marimo` code block renders a styled placeholder:

````markdown
```marimo
_notebooks/finances.py
```
````

## Development

```bash
pnpm install
pnpm dev    # watch build
pnpm build  # type-check + production build
```

To test in a vault, symlink (or copy) this folder into
`<vault>/.obsidian/plugins/marimo/` so it contains `manifest.json`, `main.js`,
and `styles.css`, then enable "Marimo" in Community plugins.

## Direction

Reuse the WASM mount pattern from
[marimo-glance](https://github.com/marimo-team/marimo-glance) to render
notebooks live inside notes.
