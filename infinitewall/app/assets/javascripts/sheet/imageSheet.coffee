imageTemplate = "<div class='sheetBox' tabindex='-1'>
    <div class='sheet' contentType='image'>
      <div class='sheetTopBar'>
        <h1 class='sheetTitle' contenteditable='true'> New Sheet </h1>
      </div>
      <div class='sheetImage'></div>
      <div class='sheetText'>
        <div class='sheetTextField' contenteditable='true'>
        </div>
      </div>
      <div class='resizeHandle'></div>
    </div>
  </div>"

class window.ImageSheet extends Sheet
  @create: (name = "Untitled Image", content, callback) ->
    img = new Image()
    img.src = content
    img.onload = ->
      w = this.width
      h = this.height
      ratio = w / h
      
      if w > 400
        w = 400
        h = 400 / ratio

      if h > 400
        h = 400
        w = 400 * ratio
    
      x = (-w + ($(window).width()) / stage.zoom) / 2 - (stage.scaleLayerX + wall.mL.x * stage.zoom) / stage.zoom
      y = (-h + ($(window).height()) / stage.zoom) / 2 - (stage.scaleLayerY + wall.mL.y * stage.zoom) / stage.zoom
      
      title = name
      
      wallSocket.sendAction({action:"create", params:{x:x, y:y, width:w, height:h, title:title, contentType:"image", content:content}})
      if typeof callback is "function"
        callback()

  setElement: ->
    @element = $($(imageTemplate).appendTo('#sheetLayer'))
    @innerElement = @element.children('.sheet')

  constructor: (params) ->
    super(params)
    @innerElement.children('.sheetImage').css 'background-image', "url('#{params.content}')"

  attachHandler: ->
    @handler = new ImageSheetHandler(this)

  becomeActive: ->
    super()
    @innerElement.find('.sheetTopBar').show()
    @innerElement.find('.sheetText').show()

  resignActive: ->
    super()
    @innerElement.find('.sheetTopBar').hide()
    @innerElement.find('.sheetText').hide()
