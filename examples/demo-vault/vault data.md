# Reading vault data

Notebook cells run in a Python (WASM) worker — they can't touch the
filesystem, but the plugin ships an `obsidian_marimo` module that reads any vault
file: `await vault.read("path/in/vault.csv")`.

## Load a CSV from the vault

`data/sales.csv` lives next to this note.

```marimo
import marimo as mo
import csv
import io
from obsidian_marimo import vault

raw = await vault.read("data/sales.csv")
sales = [
    {"month": int(r["month"]), "region": r["region"], "revenue": float(r["revenue"])}
    for r in csv.DictReader(io.StringIO(raw))
]
mo.md(f"Loaded **{len(sales)}** rows from `data/sales.csv`")
```

## Filter + chart

```marimo
region = mo.ui.dropdown(
    ["all", "north", "south", "west"], value="all", label="region"
)
region
```

```marimo
import matplotlib.pyplot as plt

selected = [r for r in sales if region.value in ("all", r["region"])]
plt.figure(figsize=(8, 3))
for reg in sorted({r["region"] for r in selected}):
    pts = [r for r in selected if r["region"] == reg]
    plt.plot([r["month"] for r in pts], [r["revenue"] for r in pts],
             marker="o", label=reg)
plt.xlabel("month"); plt.ylabel("revenue")
plt.legend(loc="upper left")
plt.tight_layout()
plt.gca()
```

```marimo
mo.ui.table(selected, label="filtered rows", page_size=6)
```

## Read another note

```marimo
note_text = await vault.read("marimo demo.md")
words = note_text.split()
fences = note_text.count("```") // 2
mo.md(
    f"`marimo demo.md`: **{len(words)}** words, "
    f"**{fences}** fenced blocks, {len(note_text)} characters"
)
```
