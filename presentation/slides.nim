import nimib, nimiSlides, p5
import arraymancer, std / [strutils]

# Init
nbInit(theme=revealTheme)

nb.useLatex()
nbUseP5()

template nbImage(src: string, size: string, caption = "") =
  nbRawHtml: hlHtml"""<img src="$1" style="max-width: $2; margin: 0px;"/><p style="font-size: 16px; margin: 0px;">$3</p>""" % [src, size, caption]

template fontSize(size: int, body: untyped) =
  nbRawHtml: hlHtml"""<div style="font-size: $1px">""" % [$size]
  body
  nbRawHtml: hlHtml"""</div>"""

template listText(s: string) =
  listItem:
    nbText:
      s

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

Supervisor: Davoud Mirzaei
"""
  nbRawHtml: hlHtml"""<img src="raptor.png" style="max-width: 50%;"/>"""

slide:
  nbText: hlMd"""
### Problem description
"""
  
    
  nbText: """
- Given sampled points from surface $\Gamma$, create an approximation of
$\Gamma$.
"""
  columns:
    column:
      nbImage("homer-ptcloud-lowres.png", size="45%")
    column:
      nbImage("homer-surface.png", size="45%")


slide:
  nbText: hlMd"""
### Mesh-based methods

- Intuitive approach to construct mesh from points.
- In this project we used mesh-free methods.
"""
  nbImage("piggy.png", caption="source: http://web.mit.edu/manoli/crust/www/slides/piggy.jpg", size="50%")


slide:
  nbText: hlMd"""
### Radial basis functions
- Real valued scalar function.
- Function of the distance between two points.
"""
  columns:
    column:
      nbImage("rbf_1d.png", size="45%")
    column:
      nbImage("rbf_2d.png",size="45%")

slide:
  nbImage("rbfExplain1.png")

slide:
  nbImage("rbfExplain2.png")

slide:
  nbImage("rbfExplain3.png")

slide:
  nbImage("rbfExplain4.png")

slide:
  nbImage("rbfExplain5.png")

slide:
  nbImage("rbfExplain6.png")



slide:
  nbText: hlMd"""
### Distance matrix
- Constructing a linear system for our interpolation problem.
"""

# Distance matrix
block distanceMatrix:
  nbJsFromCodeGlobal:
    import math
    from p5/p5instance_logic import globalAndLocal
    globalAndLocal:
      proc text(text: cstring, x, y: PNumber) {.importc.}
      proc textSize(size: PNumber) {.importc.}
      proc angleMode(mode: cstring) {.importc.}
      proc circle(x, y, width: PNumber) {.importc.}
      proc loadFont(path: cstring): Font {.importc.}
      proc textFont*(font: Font | cstring) {.importc.}

  template nbP5Instance(val1, val2: untyped, body: untyped) =
    let p5instanceId = "p5instance-" & $nb.newId()
    nbRawHtml: "<div id=\"" & p5instanceId & "\"></div>"
    nbJsFromCodeInBlock(p5instanceId, val1, val2):
      instance(p5instanceId):
        body

  proc toLatex[T](t: Tensor[T]): string =
    let rows = t.shape[0]
    let cols = t.shape[1]
    result = "$$\n A = \\phi \\left(\\begin{bmatrix}\n"
    for i in 0 ..< rows:
      for j in 0 ..< cols:
        result &= $t[i, j]
        if j < cols - 1:
          result &= " & " 
      result &= " \\\\\\\\ \n"

    result &= "\\end{bmatrix} \\right)\n$$"

  proc partialMatrix[T](t: Tensor[T], elements: openArray[(int, int)], highlight: openArray[(int, int)] = @[]): string =
    let rows = t.shape[0]
    let cols = t.shape[1]
    var m = newTensor[T](rows, cols)
    for i in 0 ..< rows:
      for j in 0 ..< cols:
        if (i, j) in elements or true:
          if (i, j) in highlight:
            m[i, j] = "\\\\color{green}{" & $t[i, j] & "}"
          else:
            m[i, j] = $t[i, j]
    result = m.toLatex

  let points = [(x: 120, y: 130), (200, 210), (300, 150)]
  #[var pairs: seq[(int, int)]
  for i in 0 .. points.high:
    for j in i .. points.high:
      pairs.add (i, j) ]#

  var matrix = newTensor[string](points.len, points.len)
  for i in 0 .. points.high:
    for j in 0 .. points.high:
      matrix[i, j] = "r_{$1 → $2}" % [$(i+1), $(j+1)]

  template distanceMatrixAnimation(element: tuple[i, j: int] = (-1, -1)) =
    let el = element
    slide:
      nbText: "### Distance matrix"
      adaptiveColumns:
        column:
          fontSize(30):
            nbText: matrix.partialMatrix(@[], @[el])
        column:
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

  distanceMatrixAnimation()
  distanceMatrixAnimation((i: 1, j: 2))


slide:
  nbText: hlMd"""
### RBF interpolation
Given input points $x$ and outputs $y$ we can construct a linear system of equations:
$Ac = y$ where A is our distance matrix constructed using our points $x$.

Solving this will give us $c$ which is our scaling coefficients for our RBFs.
"""

slide:
  nbText: hlMd"""
### Numerical stability
- Positive definite for numerical stability
- One such RBF is a gaussian kernel 
  $\phi(x)=e^{-\epsilon r^2}$
"""
  nbImage("rbf_guassian.png", size="45%")

slide:
  nbText: hlMd"""
### Numerical stability
- Compact support for sparsity
- One such RBF, Wendland's $C^2$ kernel

$$
\phi(r) = \begin{cases} 
(1 - \frac{r}{\epsilon})^4(4 \frac{r}{\epsilon} + 1) & r <= \epsilon \\
0 & r > \epsilon
\end{cases}
$$
""" # TODO: Fix not inline latex
  columns:
    column:
      nbImage("rbf_1d.png", size="45%")
    column:
      nbImage("rbf_2d.png",size="45%")

slide:
  nbText: hlMd"""
### RBF Interpolation in $\mathbb{R}^n$
- Easy since Euclidian norm is defined in any $\mathbb{R}^n$.


"""
  columns:
    column:
      nbImage("mesh_peaks.png", size="45%")
    column:
      nbImage("rbf_peaks.png",size="45%")


# TODO: Generate images on transparent!

slide:
  nbText: hlMd"""
### Localization
### Partition of unity
"""

slide:
  nbText: hlMd"""
### Off-point method  
"""

block:
  template nbP5Instance(val1: untyped, body: untyped) =
    let p5instanceId = "p5instance-" & $nb.newId()
    nbRawHtml: "<div id=\"" & p5instanceId & "\"></div>"
    nbJsFromCodeInBlock(p5instanceId, val1):
      instance(p5instanceId):
        body

  template offPointAnimation(animationStep: int) =
    let step = animationStep
    nbP5Instance(step):
      let width = 800
      let height = 600
      let r = 120.0
      let dotColor = "green"
      let dotWeight = 10
      let arrowColor = "white"
      let arrowWeight = 5

      setup:
        proc drawArrow(startX, startY, endX, endY: PNumber) =
          stroke(arrowColor)
          strokeWeight(arrowWeight)
          fill(arrowColor)
          line(startX, startY, endX, endY)
          push()
          let angle = arctan2(startY - endY, startX - endX)
          translate(endX, endY)
          angleMode("radians")
          rotate(angle - math.PI / 2)
          let offset = 10
          triangle(-offset*0.5, offset, offset*0.5, offset, 0, -offset/2)
          pop()

        proc drawDotCircle(drawNormals = false) =
          for angle in countup(0, 360, 30):
            let x = math.cos(angle.degToRad) * r
            let y = math.sin(angle.degTorad) * r
            if drawNormals:
              let x2 = x * 1.3
              let y2 = y * 1.3
              drawArrow(x + math.cos(angle.degToRad) * dotWeight / 2, y + math.sin(angle.degTorad) * dotWeight / 2, x2, y2)
            stroke(dotColor)
            strokeWeight(dotWeight)
            point(x, y)
            

        proc drawCoordinates(first, second: cstring) =
          push()
          translate(-width / 2 * 0.8, height / 2 * 0.8)
          drawArrow(0,0, 50, 0) # horizontal
          drawArrow(0,0, 0, -50) # vertical
          fill(255)
          textSize(32)
          text(first, 50, 30)
          text(second, -30, -50)
          pop()

        if step in 2 .. 4:
          createCanvas(width, height, "webgl")
        else:
          createCanvas(width, height)
          translate(width / 2, height / 2)
        
        angleMode("degrees")
        background(0)
        if step == 0:
          drawDotCircle()
          drawCoordinates("x", "y")
        if step == 1:
          drawDotCircle(true)
          drawCoordinates("x", "y")
        elif step == 2:
          rotateX(60)
          drawDotCircle(true)
        elif step == 3:
          let sca = 2
          rotateX(60)
          scale(sca)
          translate(-r, -r)
          drawDotCircle(true)
        elif step == 4:
          let sca = 3
          rotateX(89)
          scale(sca)
          translate(-r, -r)
          drawDotCircle(true)
        # Positive gradient
        elif step == 5:
          stroke(dotColor)
          strokeWeight(dotWeight)
          point(0, 0)
          drawArrow(dotWeight / 2, 0, r, 0)
          drawCoordinates("x", "z")
        elif step == 6:
          stroke(dotColor)
          strokeWeight(dotWeight)
          point(0, 0)
          drawArrow(dotWeight / 2, 0, r, 0)
          drawArrow(r, 0, r, -r)
          drawCoordinates("x", "z")
        elif step == 7:
          stroke(dotColor)
          strokeWeight(dotWeight)
          point(0, 0)
          stroke(arrowColor)
          point(r, -r)
          drawCoordinates("x", "z")
        # Negative gradient
        elif step == 8:
          stroke(dotColor)
          strokeWeight(dotWeight)
          point(0, 0)
          drawArrow(-dotWeight / 2, 0, -r, 0)
          point(r, -r)
          drawCoordinates("x", "z")
        elif step == 9:
          stroke(dotColor)
          strokeWeight(dotWeight)
          point(0, 0)
          drawArrow(-dotWeight / 2, 0, -r, 0)
          drawArrow(-r, 0, -r, r)
          point(r, -r)
          drawCoordinates("x", "z")
        elif step == 10:
          stroke(dotColor)
          strokeWeight(dotWeight)
          point(0, 0)
          stroke(arrowColor)
          point(r, -r)
          point(-r, r)
          drawCoordinates("x", "z")
        elif step == 11:
          stroke(dotColor)
          strokeWeight(dotWeight)
          point(0, 0)
          stroke(arrowColor)
          point(r, -r)
          point(-r, r)
          stroke(dotColor)
          strokeWeight(arrowWeight)
          line(r, -r, -r, r)
          drawCoordinates("x", "z")


          
        #[ fill(255)
        rotateX(60)
        stroke(255)
        strokeWeight(2)
        fill(0)
        #circle(0, 0, 2*r)
        stroke("green")
        strokeWeight(5)
        for angle in countup(0, 360, 30):
          point(math.cos(angle.degToRad) * r, math.sin(angle.degTorad) * r) ]#
  for i in 0 .. 11:
    slide:
      nbText: "### Off-point"
      offPointAnimation(i)

slide:
  nbText: hlMd"""
### Results off-point  
"""

slide:
  nbText: hlMd"""
### The importance of $\delta$
"""

slide:
  nbText: hlMd"""
### Curl-free method  
"""

slide:
  nbText: hlMd"""
### Curl-free PU
"""

slide:
  fontSize(30):
    nbText: hlMd"""
### Benchmarks
| Method       | Construction [s] | Evaluation [s] |        Error         |
|--------------|------------------|----------------|----------------------|
| Off-point    | 96               | 5.7            | $5 \cdot 10 ^ {-8}$  |
| Off-point PU | 1.5              | 5.4            | $4 \cdot 10 ^ {-4}$  |
| Curl-free    | 93               | 5.8            | $2 \cdot 10 ^ {-15}$ |
| Curl-free PU | 4.4              | 1.9            | $6 \cdot 10 ^ {-7}$  |
"""

slide:
  nbText: hlMd"""
### Thank you for listening!  
"""

# Save & export
nbSave()