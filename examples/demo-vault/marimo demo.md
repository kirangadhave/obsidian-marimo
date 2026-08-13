# marimo demo

Two `marimo` blocks sharing one reactive notebook — move the slider and the
cell below reruns.

```marimo
import marimo as mo
slider = mo.ui.slider(0, 10, value=4, label="x")
slider
```

```marimo
mo.md(f"x² = **{slider.value ** 2}**")
```

## marimo markdown flavor

```marimo
y = slider.value + 24
y
```

This fence uses marimo's notebook-as-markdown syntax (`python {.marimo}`):

```python {.marimo}
import random
mo.md(f"A pure-python cell: {sum(range(100))}")
```

A plain python block stays a plain code block:

```python
print("not a marimo cell")
```
