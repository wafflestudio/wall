linkTemplate = "<div class = 'linkLine'></div>"

class window.LinkLine extends Moveable
  from: null
  to: null

  constructor: (from) ->
    @element = $($(linkTemplate).appendTo('#linkLayer'))
    @element.css {transformOrigin: "top"}
    @from = from
  
  getCenter: (sheetID) ->
    x: sheets[sheetID].x() + sheets[sheetID].w() / 2
    y: sheets[sheetID].y() + sheets[sheetID].h() / 2

  rotateLink: (fromX, fromY, toX, toY, isTransition = false) ->
    @rotateLink.oldTheta = 0 if undefined
    $.fn.moveFunc = if isTransition then $.fn.transition else $.fn.css

    length = Math.sqrt((fromX - toX) * (fromX - toX) + (fromY - toY) * (fromY - toY))
    newTheta = 180 / 3.14 * Math.acos((toY - fromY) / length)
    newTheta *= -1 if toX > fromX
   
    temp = @rotateLink.oldTheta
    @rotateLink.oldTheta = newTheta

    if temp > 90 and newTheta < 0 # 예전 각도가 2사분면에 있고, 새로운 각도가 1, 4 사분면으로 갈때
      newTheta += 360

    else if temp < -90 and newTheta > 0 # 예전 각도가 1사분면에 있고, 새로운 각도가 2, 3 사분면으로 갈때
      newTheta -= 360

    @element.moveFunc {
      x: fromX,
      y: fromY,
      height: length,
      rotate: newTheta
    }, =>
      if Math.abs(temp) > 90
        if newTheta > 180
          @element.css {rotate: newTheta - 360}
        else if newTheta < -180
          @element.css {rotate: newTheta + 360}
  
  followMouse: (x, y) =>
    fgC = @getCenter(@from)
    toX = x - (glob.scaleLayerXPos + wall.mL.x() * glob.zoomLevel) / glob.zoomLevel
    toY = y - (glob.scaleLayerYPos + wall.mL.y() * glob.zoomLevel) / glob.zoomLevel
    @rotateLink(fgC.x, fgC.y, toX, toY)
   
  connect: (toID) =>
    if sheets[@from].links[toID] or toID is @from
      @remove()
    else
      @to = toID
      tgC = @getCenter(@to)
      fgC = @getCenter(@from)
      @rotateLink(fgC.x, fgC.y, tgC.x, tgC.y)
      sheets[@from].links[@to] = this
      sheets[@to].links[@from] = this

  refresh: () ->
    fgC = @getCenter(@from)
    tgC = @getCenter(@to)
    @rotateLink(fgC.x, fgC.y, tgC.x, tgC.y)

  transitionRefresh: (id, x, y) ->
    centerX = sheets[id].w() / 2
    centerY = sheets[id].h() / 2

    if id is @from
      gC = @getCenter(@to)
      @rotateLink(x + centerX, y + centerY, gC.x, gC.y, true)
    else
      gC = @getCenter(@from)
      @rotateLink(gC.x, gC.y, x + centerX, y + centerY, true)

  remove: ->
    @element.remove()
