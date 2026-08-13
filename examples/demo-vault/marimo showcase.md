# marimo showcase

Every `marimo` block in this note is a cell of **one reactive notebook**.
Change any input and every dependent cell reruns automatically.

## Hello, reactivity

```marimo
import marimo as mo
name = mo.ui.text(value="world", label="Your name")
name
```

```marimo
mo.md(f"Hello, **{name.value}**! 👋")
```

## Sliders driving computation

Two inputs, one derived dataset — used by the chart and table below.

```marimo
n = mo.ui.slider(10, 500, value=120, label="points")
noise = mo.ui.slider(0.0, 2.0, value=0.4, step=0.1, label="noise")
mo.hstack([n, noise], justify="start", gap=2)
```

```marimo
import math
import random
xs = [i / n.value * 4 * math.pi for i in range(n.value)]
ys = [math.sin(x) + random.gauss(0, noise.value) for x in xs]
mo.md(f"Generated **{len(xs)}** noisy sine points (noise σ = {noise.value})")
```

## Chart

matplotlib is fetched on first use (needs network once), then drag the
sliders above and watch the figure rerender.

```marimo
import matplotlib.pyplot as plt
plt.figure(figsize=(8, 3))
plt.plot(xs, ys, ".", markersize=4, alpha=0.5, label="noisy")
plt.plot(xs, [math.sin(x) for x in xs], linewidth=2, label="sin(x)")
plt.legend(loc="upper right")
plt.title("noisy sine")
plt.tight_layout()
plt.gca()
```

## Table

```marimo
rows = [
    {"i": i, "x": round(x, 2), "y": round(y, 2)}
    for i, (x, y) in enumerate(zip(xs, ys))
]
mo.ui.table(rows, label="the data", page_size=8)
```

## Selection

```marimo
flavor = mo.ui.dropdown(
    ["vanilla", "chocolate", "matcha"], value="matcha", label="flavor"
)
flavor
```

```marimo
prices = {"vanilla": 3.00, "chocolate": 3.50, "matcha": 4.25}
mo.md(f"A scoop of **{flavor.value}** costs **${prices[flavor.value]:.2f}** 🍦")
```

## marimo markdown flavor

This fence uses marimo's notebook-as-markdown syntax and joins the same
notebook:

```python {.marimo}
mo.md(
    f"A `python {{.marimo}}` cell — stdlib only, fully offline: "
    f"sum(1..100) = **{sum(range(101))}**"
)
```

A plain python block stays a plain code block:

```python
print("not a marimo cell")
```
