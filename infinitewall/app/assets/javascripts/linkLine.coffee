linkTemplate = "<div class = 'linkLine'></div>"

class window.LinkLine extends Moveable
  from: null
  to: null
  oldTheta: 0

  constructor: (from) ->
    @element = $($(linkTemplate).appendTo('#linkLayer'))
    @element.css {transformOrigin: "left"}
    @from = from
  
  getCenter: (sheetID) ->
    x: sheets[sheetID].x() + sheets[sheetID].w() / 2
    y: sheets[sheetID].y() + sheets[sheetID].h() / 2

  rotateLink: (fromX, fromY, toX, toY, isTransition = false) ->
    plus = false
    minus = false

    $.fn.moveFunc = if isTransition then $.fn.transition else $.fn.css

    length = Math.sqrt((fromX - toX) * (fromX - toX) + (fromY - toY) * (fromY - toY))
    newTheta = 180 / 3.14 * Math.atan2(toY - fromY, toX - fromX)
    
    temp = @oldTheta
    @oldTheta = newTheta
    
    if temp < -90 and newTheta > 90
      newTheta -= 360
      minus = true
    else if temp > 90 and newTheta < -90
      newTheta += 360
      plus = true

    @element.moveFunc {
      x: fromX,
      y: fromY,
      width: length,
      rotate: newTheta
    }, =>
      @element.css {rotate: newTheta - 360} if plus
      @element.css {rotate: newTheta + 360} if minus
  
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

  transitionRefresh: (id, x, y, w, h) ->

    if id is @from
      gC = @getCenter(@to)
      @rotateLink(x + (w / 2), y + (h / 2), gC.x, gC.y, true)
    else
      gC = @getCenter(@from)
      @rotateLink(gC.x, gC.y, x + (w / 2), y + (h / 2), true)

  remove: ->
    @element.remove()
