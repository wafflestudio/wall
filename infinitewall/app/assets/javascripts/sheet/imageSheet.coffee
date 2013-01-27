imageTemplate = "
  <div class='sheetBox' tabindex='-1'>
    <div class='sheet' contentType='image'>
      <div class='sheetTopBar'>
        <h1 class='sheetTitle' contenteditable='true'> New Sheet </h1>
      </div>
      <div class='sheetImage'></div>
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
    
      x = (-w + ($(window).width()) / glob.zoomLevel) / 2 - (glob.scaleLayerX + wall.mL.x() * glob.zoomLevel) / glob.zoomLevel
      y = (-h + ($(window).height()) / glob.zoomLevel) / 2 - (glob.scaleLayerY + wall.mL.y() * glob.zoomLevel) / glob.zoomLevel
      
      title = name
      
      wallSocket.send({action:"create", params:{x:x, y:y, width:w, height:h, title:title, contentType:"image", content:content}})
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
