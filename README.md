# nodejs-tiddlywiki-to-md
Convert tiddlywiki tiddles to md

# Init project : install packages from packages.json
```
npm install
```

# Run the tool
```
node start
```

# Conversion table

| tiddlywiki | md |
|----|----|
| `''bold''` | **bold** |
| `//italic//` | *italic* |
| `__underscore__` | <u>underscore</u> |
| `^^superscript^^` | <sup>superscript<sup> |
| `,,subscript,,` | <sub>subscript</sub> |
| `~~strikethrough~~` | ~~strikethrough~~ |
| `<x-tex>\sqrt{E[(\mathbf{x}-\mu_x)^2]}</x-tex>` | $\sqrt{E[(\mathbf{x}-\mu_x)^2]}$ |
| `<<img src:"media/ai/rs/800px-correlation_examples.png" width:200 align:right>>` | <img style="border: 0px none; float: right; margin: 0px;0px 0px 1.5em;width:200px" src="data/media/ai/rs/800px-correlation_examples.png"> |

# Tools for iPhone

* Editorials : http://omz-software.com/editorial/
