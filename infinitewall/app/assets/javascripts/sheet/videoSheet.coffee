define ["./sheet", "./videoSheetHandler", "templatefactory", "jquery"], (Sheet, VideoSheetHandler, TemplateFactory, $) ->

  class VideoSheet extends Sheet
    @create: (name = "Untitled Video", content, callback) ->

    setElement: ->
      videoTemplate = TemplateFactory.makeTemplate("videoSheet")
      @element = $(videoTemplate).appendTo('#sheetLayer')
      @innerElement = @element.children('.sheet')

    constructor: (params) ->
      super(params)
      @innerElement.children('.sheetVideo').html(params.content)

    attachHandler: ->
      @handler = new VideoSheetHandler(this)
