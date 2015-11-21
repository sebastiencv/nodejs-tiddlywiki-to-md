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

[More details](more.md)

[More 2 details](more%202.md)

# OSX editor

* MacDown http://macdown.uranusjr.com/, https://github.com/uranusjr/macdown

# Tools for iPhone

* Editorials : http://omz-software.com/editorial/

# Math library

* http://khan.github.io/KaTeX/

# Analysis of atom/markdown-preview

* https://github.com/atom/markdown-preview/blob/master/package.json

## Rendering

* Two triggers in `lib/main.coffee` :
  * via `atom.workspace.addOpener` in case of opening a file
    * in `lib/markdown-preview-view.coffee` : `renderer.toDOMFragment text, @getPath(), @getGrammar()`
      * in `lib/renderer.coffee` : 
  * via toggle that call back `atom.workspace.open(...)`
