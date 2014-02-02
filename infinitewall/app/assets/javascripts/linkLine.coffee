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

    pathString: (fromX, fromY, toX, toY) ->
      curveX1 = (fromX + toX) / 2
      curveY1 = fromY
      curveX2 = toX# (fromX + toX) / 2
      curveY2 = toY
      "M" + fromX + "," + fromY + "C" + curveX1 + "," + curveY1 + "," + curveX2 + "," + curveY2 + "," + toX + "," + toY

    rotateLink: (fromX, fromY, toX, toY, isTransition = false) ->
      line_str = @pathString(fromX, fromY, toX, toY)
      bbox = Raphael.pathBBox(line_str)
      transform_str = "T" + -bbox.x + "," + -bbox.y
      newline_str = Raphael.transformPath(line_str, transform_str)

      len = Raphael.getTotalLength(newline_str)
      pt1 = Raphael.getPointAtLength(newline_str, len - 0.1)
      pt2 = Raphael.getPointAtLength(newline_str, len - 0.2)
      angle = Raphael.angle(pt1.x, pt1.y, pt2.x, pt2.y)
      arrow_path = "M -10,-5 L 0,0 L -10,5 Z"
      arrow_transform = "t#{pt1.x},#{pt1.y} r#{angle},0,0"

      if @line == null
        @line = @paper.path(newline_str)
        @line.attr("stroke", "black")
        @line.attr("stroke-width", "3")
        @arrow = @paper.path(arrow_path)
        @arrow.attr("stroke", "black")
        @arrow.attr("fill", "black")
        @arrow.attr("stroke-width", "3")
        @arrow.transform(arrow_transform)
      else
        if isTransition
          @line.animate {path: newline_str}, 400, 'ease'
          @arrow.animate {transform: arrow_transform}, 400, 'ease'
        else
          @line.attr("path", newline_str)
          @arrow.attr("transform", arrow_transform)
       
      if isTransition
        @txywh(bbox.x, bbox.y, bbox.width + 100, bbox.height + 100)
      else
        @xywh(bbox.x, bbox.y, bbox.width + 100, bbox.height + 100)

    bordered: (x1, y1, w1, h1, x2, y2, w2, h2) ->
      # path1: line from-to the box centers
      path1 = "M #{x1+w1/2} #{y1+h1/2} L #{x2+w2/2} #{y2+h2/2}"
      # path2 & 3: bounding boxes
      path2 = "M #{x1} #{y1} L #{x1+w1} #{y1} L #{x1+w1} #{y1+h1} L #{x1} #{y1+h1} L #{x1} #{y1}"
      path3 = "M #{x2} #{y2} L #{x2+w2} #{y2} L #{x2+w2} #{y2+h2} L #{x2} #{y2+h2} L #{x2} #{y2}"
      i1 = Raphael.pathIntersection path1, path2
      i2 = Raphael.pathIntersection path1, path3

      [cx1,cy1] = [x1 + w1/2, y1 + h1/2]
      [cx2,cy2] = [x2 + w2/2, y2 + h2/2]

      if i1.x?
        cx1 = i1.x
        cy1 = i1.y
      else if i1 instanceof Array
          for intersection in i1
            {x: xx1, y:yy1} = intersection
            cx1 = xx1
            cy1 = yy1

      if i2.x?
        cx2 = i2.x
        cy2 = i2.y
      else if i2 instanceof Array
          for intersection in i2
            {x:xx2,y:yy2} = intersection
            cx2 = xx2
            cy2 = yy2
     
      [cx1, cy1, cx2, cy2]


    followMouse: (x, y) =>
      toX = x - (stage.scaleLayerX + wall.mL.x * stage.zoom) / stage.zoom
      toY = y - (stage.scaleLayerY + wall.mL.y * stage.zoom) / stage.zoom
      [fx, fy, tx, ty] = @bordered(@from.x, @from.y, @from.w, @from.h, toX, toY, 0,0)
      @rotateLink(fx, fy, tx, ty)
     
    connect: (toID) =>
      @to = stage.sheets[toID]
      [fx, fy, tx, ty] = @bordered(@from.x, @from.y, @from.w, @from.h, @to.x, @to.y, @to.w, @to.h)
      @rotateLink(fx, fy, tx, ty)

      @id = "linkLine_" + @from.id + "_" + @to.id
      @element.attr('id', @id)
      @from.links[@to.id] = this
      @to.links[@from.id] = this

    refresh: (isTransition = false) ->
      [fx, fy, tx, ty] = @bordered(@from.x, @from.y, @from.w, @from.h, @to.x, @to.y, @to.w, @to.h)
      @rotateLink(fx, fy, tx, ty, isTransition)

    transitionRefresh: (id, x, y, w, h) ->
      if stage.sheets[id] is @from
        [fx, fy, tx, ty] = @bordered(x, y, w, h, @to.x, @to.y, @to.w, @to.h)
        @rotateLink(fx, fy, tx, ty, true)
      else
        [fx, fy, tx, ty] = @bordered(@from.x, @from.y, @from.w, @from.h, x, y, w, h)
        @rotateLink(fx, fy, tx, ty, true)

    remove: ->
      console.log "remove called"
      #@element.transition {opacity:0, scale: 1.25}, 100, =>
      @line.remove()
      @paper.remove()
      @element.remove()
