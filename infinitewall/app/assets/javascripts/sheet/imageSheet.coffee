imageTemplate = "<div class='sheetBox' tabindex='-1'><div class='sheet' contentType='image'><div class='sheetTopBar'><h1 class='sheetTitle' contenteditable='true'> New Sheet </h1></div><div class='sheetImage'></div><div class='resizeHandle'></div></div><a class = 'boxClose'>x</a></div>"

class window.ImageSheet extends Sheet
  @create: (content) ->
    img = new Image()
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
    
      x = (-w + ($(window).width() - 225) / glob.zoomLevel) / 2 - (glob.scaleLayerXPos + (parseInt ($('#moveLayer').css 'x')) * glob.zoomLevel) / glob.zoomLevel
      y = (-h + ($(window).height() - 74) / glob.zoomLevel) / 2 - (glob.scaleLayerYPos + (parseInt ($('#moveLayer').css 'y')) * glob.zoomLevel) / glob.zoomLevel

      title = "Untitled Image"

      wallSocket.send({action:"create", params:{x:x, y:y, width:w, height:h, title:title, contentType:"image", content:content}})

    img.src = content

  setElement: () ->
    @element = $($(imageTemplate).appendTo('#moveLayer'))

  constructor: (params) ->
    super(params)

    @element.children('.sheet').css 'width', params.width + 'px'
    @element.children('.sheet').css 'height', params.height + 'px'
    @element.children('.sheet').children('.sheetImage').css 'background', "url('#{params.content}') no-repeat"
    @element.children('.sheet').children('.sheetImage').css 'background-size', '100%'

  attachSocketAction: () ->
    super()

  attachHandler: () ->
    @handler = new ImageSheetHandler(this)
    #imageSheetHandler(this)
