#linkTemplate = "<div class='linkLine'></div>"

class window.LinkLine extends Movable
  paper: null
  line: null

  from: null
  to: null
  oldTheta: 0

  constructor: (from) ->
    @id = "linkLine_" + from + "_null"
    linkTemplate = "<div id='" + @id + "' class='linkLine'></div>"

    @element = $($(linkTemplate).appendTo('#linkLayer'))
    gC = @getCenter(from)
    @element.css {position: 'absolute', top: gC.y, left: gC.x, width: 500, height: 500}
    @paper = Raphael(@id, '100%', '100%')
    @from = from
  
  getCenter: (sheetID) ->
    x: sheets[sheetID].x() + sheets[sheetID].w() / 2
    y: sheets[sheetID].y() + sheets[sheetID].h() / 2

  rotateLink: (fromX, fromY, toX, toY, isTransition = false) ->
    curveX1 = (fromX + toX) / 2
    curveY1 = fromY
    curveX2 = (fromX + toX) / 2
    curveY2 = toY
    line_str = "M" + fromX + "," + fromY + "C" + curveX1 + "," + curveY1 + "," + curveX2 + "," + curveY2 + "," + toX + "," + toY

    bbox = Raphael.pathBBox(line_str)
    transform_str = "T" + -bbox.x + "," + -bbox.y
    newline_str = Raphael.transformPath(line_str, transform_str)

    if @line == null
      @line = @paper.path(newline_str)
      @line.attr("stroke", "black")
      @line.attr("stroke-width", "3")
    else
      if isTransition
        @line.animate {path: newline_str}, 400, 'ease'
      else
        @line.attr("path", newline_str)
      
    @element.css {position: 'absolute', width: bbox.width+100, height: bbox.height+100}
    if @element.attr('top') != bbox.y
      @element.css {top: bbox.y}
    if @element.attr('left') != bbox.x
      @element.css {left: bbox.x}

    #TODO: different movement on transition case?

  followMouse: (x, y) =>
    fgC = @getCenter(@from)
    toX = x - (glob.scaleLayerXPos + wall.mL.x() * glob.zoomLevel) / glob.zoomLevel
    toY = y - (glob.scaleLayerYPos + wall.mL.y() * glob.zoomLevel) / glob.zoomLevel
    @rotateLink(fgC.x, fgC.y, toX, toY)
   
  connect: (toID) =>
    @to = toID
    tgC = @getCenter(@to)
    gC = @getCenter(@from)
    @rotateLink(gC.x, gC.y, tgC.x, tgC.y)

    @id = "linkLine_" + @from + "_" + @to
    @element.attr('id', @id)
    sheets[@from].links[@to] = this
    sheets[@to].links[@from] = this

  refresh: ->
    fgC = @getCenter(@from)
    tgC = @getCenter(@to)
    @rotateLink(fgC.x, fgC.y, tgC.x, tgC.y)

  transitionRefresh: (id, x, y, w, h) ->
    if id is @from
      gC = @getCenter(@to)
      @rotateLink(x + (w / 2), y + (h / 2), gC.x, gC.y, true)
    else
      gC = @getCenter(@from)
      @rotateLink(gC.x, gC.y, x + (w / 2), y + (h / 2), true)

  remove: ->
    @line.remove()
    @paper.remove()
    @element.remove()

