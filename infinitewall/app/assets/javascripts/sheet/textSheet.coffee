textTemplate = "<div class='sheetBox' tabindex='-1'><div class='sheet' contentType='text'><div class='sheetTopBar'><h1 class='sheetTitle' contenteditable='true'> New Sheet </h1></div><div class='sheetText'><div class='sheetTextField' contenteditable='true'><div> <br></div></div></div><div class='resizeHandle'></div></div><a class = 'boxClose'>x</a></div>"

class window.TextSheet extends Sheet
  @create: (content) ->
    x = Math.random() * ($(window).width() - 225) * 0.9 / glob.zoomLevel - (glob.scaleLayerXPos + (parseInt ($('#moveLayer').css 'x')) * glob.zoomLevel) / glob.zoomLevel
    y = Math.random() * ($(window).height() - 74) * 0.9 / glob.zoomLevel - (glob.scaleLayerYPos + (parseInt ($('#moveLayer').css 'y')) * glob.zoomLevel) / glob.zoomLevel
    w = 300
    h = 300

    title = "Untitled Text"
    content = "<div> " + content + "<br></div>"

    wallSocket.send({action:"create", params:{x:x, y:y, width:w, height:h, title:title, contentType:"text", content:content}})

  setElement: () ->
    @element = $($(textTemplate).appendTo('#moveLayer'))

  constructor: (params) ->
    super(params)
    
    @element.find('div.sheetTextField').html(params.content)
    @element.find('div.sheetTextField').wallEditor()

  attachHandler: () ->
    @handler = new TextSheetHandler(this)

  socketSetText: (e) ->
    console.log "asdfasdf"
    wallSocket.send {
      action : 'setText',
      params : {
        id : self.id,
        text : self.element.find('div.sheetTextField').html(),
        keyCode : self.element.find('div.sheetTextField')[0].keyCode,
        beforeAndAfter : self.element.find('div.sheetTextField')[0].beforeAndAfter
      }
    }

  setText: (params) ->
    serverContent = params.text
    keyCode = params.keyCode
    beforeAndAfter = params.beforeAndAfter

    console.log 'setText'
    # strip tag
    serverContent = serverContent.replace(/(<([^>]+)>)/ig, "")
    if keyCode == 46
    else if keyCode < 16 || keyCode > 18 && keyCode < 37 || keyCode > 40
      @element.find('div.sheetTextField').html(serverContent)
      @element.find('div.sheetTextField').trigger('setCursor', beforeAndAfter)
