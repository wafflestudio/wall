define ["jquery", "raphael", "movable"], ($, Raphael, Movable) ->
  class LinkLine extends Movable
    paper: null
    line: null

    from: null
    to: null
    oldTheta: 0

    constructor: (fromID) ->
      super(false)
      @id = "linkLine_" + fromID + "_null"
      @element = $($("<div id='" + @id + "' class='linkLine'></div>").appendTo('#linkLayer'))
      @paper = Raphael(@id, '100%', '100%')
      @from = stage.sheets[fromID]
      @x = @from.cx
      @y = @from.cy

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
       
      if isTransition
        @txywh(bbox.x, bbox.y, bbox.width + 100, bbox.height + 100)
      else
        @xywh(bbox.x, bbox.y, bbox.width + 100, bbox.height + 100)

    followMouse: (x, y) =>
      toX = x - (stage.scaleLayerX + wall.mL.x * stage.zoom) / stage.zoom
      toY = y - (stage.scaleLayerY + wall.mL.y * stage.zoom) / stage.zoom
      @rotateLink(@from.cx, @from.cy, toX, toY)
     
    connect: (toID) =>
      @to = stage.sheets[toID]
      @rotateLink(@from.cx, @from.cy, @to.cx, @to.cy)

      @id = "linkLine_" + @from.id + "_" + @to.id
      @element.attr('id', @id)
      @from.links[@to.id] = this
      @to.links[@from.id] = this

    refresh: (isTransition = false) ->
      @rotateLink(@from.cx, @from.cy, @to.cx, @to.cy, isTransition)

    transitionRefresh: (id, x, y, w, h) ->
      if stage.sheets[id] is @from
        @rotateLink(x + (w / 2), y + (h / 2), @to.cx, @to.cy, true)
      else
        @rotateLink(@from.cx, @from.cy, x + (w / 2), y + (h / 2), true)

    remove: ->
      console.log "remove called"
      #@element.transition {opacity:0, scale: 1.25}, 100, =>
      @line.remove()
      @paper.remove()
      @element.remove()
