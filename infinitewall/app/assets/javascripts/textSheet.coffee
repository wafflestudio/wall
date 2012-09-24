textTemplate = "<div class='sheetBox' tabindex='-1'><div class='sheet' contentType='text'><div class='sheetTopBar'><h1 class='sheetTitle' contenteditable='true'> New Sheet </h1></div><div class='sheetText'><textarea class='sheetTextField'></textarea></div><div class='resizeHandle'></div></div><a class = 'boxClose'>x</a></div>"

class window.TextSheet extends Sheet
  @create: (content) ->
    x = Math.random() * ($(window).width() - 225) * 0.9 / glob.zoomLevel - (glob.scaleLayerXPos + (parseInt ($('#moveLayer').css 'x')) * glob.zoomLevel) / glob.zoomLevel
    y = Math.random() * ($(window).height() - 74) * 0.9 / glob.zoomLevel - (glob.scaleLayerYPos + (parseInt ($('#moveLayer').css 'y')) * glob.zoomLevel) / glob.zoomLevel
    w = 300
    h = 300

    title = "Untitled Text"

    wallSocket.send({action:"create", params:{x:x, y:y, width:w, height:h, title:title, contentType:"text", content:content}})

  setElement: () ->
    @element = $($(textTemplate).appendTo('#moveLayer'))

  constructor: (params) ->
    super(params)
    
    @element.find('textarea').html(params.content)
    $('#sheet' + @id + ' textarea.sheetTextField').redactor {
      autoresize : true,
      air : true,
      airButtons : ['formatting', '|', 'bold', 'italic', 'deleted']
    }

  attachSocketAction: () ->
    super()

    self = this
    @element.on 'setText', (e) ->
      wallSocket.send {action : 'setText', params : {id : self.id, text : self.element.find('textarea').val(), cursor : 1}}

  attachHandler: () ->
    #@handler = new TextSheetHandler(this)
    textSheetHandler(@element)

  setText: (params) ->
    #set text
    console.log("asdfasdfasdf")
    elem = $(@element.find('textarea.sheetTextField'))
    text1 = elem.getCode()
    text2 = params.text
    patch_text = diff_launch text1, text2
    patch = patch_launch text1, patch_text
    cursor = elem.getCursorPosition()

    console.log "a: #{text1}"
    console.log "b: #{text2}"
    console.log "c: #{patch_text}"
    console.log "d: #{patch}"

    elem.setCode(patch)
    elem.setCursorPosition(cursor)



