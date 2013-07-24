define ["./sheet", "./imageSheetHandler", "templatefactory", "jquery"], (Sheet, ImageSheetHandler, TemplateFactory, $) ->
  class ImageSheet extends Sheet
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
        
        action = {action:"create", params:{x:x, y:y, width:w, height:h, title:title, contentType:"image", content:content}}
        histObj = {action:"remove", params:{}}
        wallSocket.sendAction(action, histObj)
        #일단 서버로 보내고, 응답이 오면 만들어짐

        if typeof callback is "function"
          callback()

    setElement: ->
      imageTemplate = TemplateFactory.makeTemplate("imageSheet")
      @element = $(imageTemplate).appendTo('#sheetLayer')
      @innerElement = @element.children('.sheet')

    constructor: (params) ->
      super(params)
      @innerElement.children('.sheetImage').css 'background-image', "url('#{params.content}')"
      @contentType = "imageSheet"

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
