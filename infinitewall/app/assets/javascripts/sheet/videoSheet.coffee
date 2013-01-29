videoTemplate = "<div class='sheetBox' tabindex='-1'>
  <div class='sheet' contentType='image'>
    <div class='sheetTopBar'>
      <h1 class='sheetTitle' contenteditable='true'> New Sheet </h1>
    </div>
    <div class='sheetVideo'></div>
    <div class='resizeHandle'></div>
  </div>
</div>"

class window.VideoSheet extends Sheet
  @create: (name = "Untitled Video", content, callback) ->

  setElement: ->
    @element = $($(imageTemplate).appendTo('#sheetLayer'))
    @innerElement = @element.children('.sheet')

  constructor: (params) ->
    super(params)
    @innerElement.children('.sheetVideo').css 'background-image', "url('#{params.content}')"

  attachHandler: ->
    @handler = new VideoSheetHandler(this)
