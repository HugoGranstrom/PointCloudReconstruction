import nimib, nimiSlides, p5
import arraymancer, std / [strutils]

# Init
nbInit(theme=revealTheme)

nb.useLatex()
nbUseP5()

template nbImage(src: string, size: string) =
  nbRawHtml: hlHtmlF"""<img src="{src}" style="max-width: 50%;"/>"""

let nimYellow = "#FFE953"
nb.addStyle: """
:root {
  --r-background-color: #181922;
  --r-heading-color: $1;
  --r-link-color: $1;
  --r-selection-color: $1;
  --r-link-color-dark: darken($1 , 15%)
}
.reveal ul, .reveal ol {
  display: block;
  text-align: left;
}
li::marker {
  color: $1;
  content: "»";
}
li {
  padding-left: 12px;
}
""" % [nimYellow]

# Title slide
slide:
  nbText: hlMd"""
## Surface reconstruction using radial basis functions

Group 19: Hugo Granström & Caspar Norée Palm
"""
  nbRawHtml: hlHtml"""<img src="raptor.png" style="max-width: 50%;"/>"""

slide:
  nbText: hlMd"""
## Problem description
"""
  
    
  nbText: """
- Given sampled points from surface $\Gamma$, create an approximation of
$\Gamma$.
"""
  columns:
    column:
      nbImage("homer-ptcloud.png")
    column:
      nbImage("homer-surface.png")


# Distance matrix
block distanceMatrix:
  nbJsFromCodeGlobal:
    from p5/p5instance_logic import globalAndLocal
    globalAndLocal:
      proc text(text: cstring, x, y: PNumber) {.importc.}
      proc textSize(size: PNumber) {.importc.}

  template nbP5Instance(val1, val2: untyped, body: untyped) =
    let p5instanceId = "p5instance-" & $nb.newId()
    nbRawHtml: "<div id=\"" & p5instanceId & "\"></div>"
    nbJsFromCodeInBlock(p5instanceId, val1, val2):
      instance(p5instanceId):
        body

  proc toLatex[T](t: Tensor[T]): string =
    let rows = t.shape[0]
    let cols = t.shape[1]
    result = "$$\n\\begin{bmatrix}\n"
    for i in 0 ..< rows:
      for j in 0 ..< cols:
        result &= $t[i, j]
        if j < cols - 1:
          result &= " & " 
      result &= " \\\\\\\\ \n"

    result &= "\\end{bmatrix}\n$$"

  proc partialMatrix[T](t: Tensor[T], elements: openArray[(int, int)], highlight: openArray[(int, int)] = @[]): string =
    let rows = t.shape[0]
    let cols = t.shape[1]
    var m = newTensor[T](rows, cols)
    for i in 0 ..< rows:
      for j in 0 ..< cols:
        if (i, j) in elements:
          if (i, j) in highlight:
            m[i, j] = "\\\\color{green}{" & $t[i, j] & "}"
          else:
            m[i, j] = $t[i, j]
    result = m.toLatex

  let points = [(x: 120, y: 130), (200, 210), (300, 150)]
  var pairs: seq[(int, int)]
  for i in 0 .. points.high:
    for j in i .. points.high:
      pairs.add (i, j)

  var matrix = newTensor[string](points.len, points.len)
  for i in 0 .. points.high:
    for j in 0 .. points.high:
      matrix[i, j] = "r_{$1 → $2}" % [$(i+1), $(j+1)]

  var elements: seq[(int, int)]
  for (i, j) in pairs:
    elements.add (i, j)
    elements.add (j, i)
    slide:
      nbText: "## Distance matrix"
      columns:
        column:
          nbText: matrix.partialMatrix(elements, @[(i, j), (j, i)])
        column:
          let el = (i: i, j: j)
          nbP5Instance(points, el):
            setup:
              createCanvas(400, 400)
              #background(200)
              background(0)
              fill(0)
              textSize(35)
              let i = el.i
              let j = el.j
              for idx, (x, y) in points:
                if idx in [i, j]:
                  fill("rgb(0,255,0)")
                else:
                  fill(255)
                ellipse(x, y, 30, 30)
                text($(idx+1), x-10, y + 50)
              strokeWeight(3)
              stroke(255)
              line(points[i].x, points[i].y, points[j].x, points[j].y)

# Save & export
nbSave()