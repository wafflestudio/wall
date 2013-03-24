
$(
  ()->
    rangy.init()
)
# import module
detectOperation = modules.detectOperation
spliceString = modules.spliceString
Operation = modules.Operation
CharWithState = modules.CharWithState
StringWithState = modules.StringWithState

textTemplate = "<div class='sheetBox' tabindex='-1'>
    <div class='sheet' contentType='text'>
      <div class='sheetTopBar'>
        <h1 class='sheetTitle' contenteditable='true'> New Sheet </h1>
      </div>
      <div class='sheetText'>
        <div class='sheetTextField' contenteditable='true'>
        </div>
      </div>
      <div class='resizeHandle'></div>
    </div>
  </div>"


class window.TextSheet extends Sheet
  @create: (content) ->
    x = Math.random() * ($(window).width() - 225) * 0.9 / stage.zoom - (stage.scaleLayerX + (parseInt ($('#moveLayer').css 'x')) * stage.zoom) / stage.zoom
    y = Math.random() * ($(window).height() - 74) * 0.9 / stage.zoom - (stage.scaleLayerY + (parseInt ($('#moveLayer').css 'y')) * stage.zoom) / stage.zoom
    w = 300
    h = 300

    title = "Untitled Text"

    wallSocket.sendAction({action:"create", params:{x:x, y:y, width:w, height:h, title:title, contentType:"text", content:content}})

  setElement: ->
    @element = $($(textTemplate).appendTo('#sheetLayer'))
    @innerElement = @element.children('.sheet')

  constructor: (params, timestamp) ->
    super(params)
    textfield = @element.find('.sheetTextField')
    @baseText = params.content # used for rebuilding with @pending 
    @pending = [] # {basetimestamp, userid, original change, }
    @msgId = 0
    @id = params.id
    @textfield = textfield
    @timestamp = timestamp

    @element.find('.sheetTextField').html(params.content)

    @savedText = params.content
    textfield.html(params.content)

    if textfield.html() != params.content
        console.warn("browser altered content! :", textfield.html(), ":", params.content)

    ##### Text change detection ###### 
    savedRange = null
    selection = rangy.getSelection()
    
    @setRange = (start, end) ->
      html = textfield.html()
      length = html.length

      backwards = start > end
      if start < end
        s = start
        e = end
      else
        s = end
        e = start

      if s == e
        html = html.substr(0,s) + '<a class="rangeCollapsed"></a>' + html.substr(s)
        textfield.html(html)
        node = textfield.find('a.rangeCollapsed').get(0)
        range = rangy.createNativeRange()
        if s > 0
          range.setEndBefore(node)
          range.collapse(false)
        else if e < length-1
          range.setStartAfter(node)
          range.collapse(true)
        else
          range.selectNode(textfield.get(0))

        node.parentNode.removeChild(node)

      else
        textfield.html(html.substr(0,s) + '<a class="rangeStart"></a>' +
          html.substr(s, e-s) + '<a class="rangeEnd"></a>' + html.substr(e))
        node1 = textfield.find('a.rangeStart').get(0)
        node2 = textfield.find('a.rangeEnd').get(0)
        #console.log(node1, node2)
        range = rangy.createNativeRange()
        range.setStartAfter(node1)
        range.setEndBefore(node2)
        node1.parentNode.removeChild(node1)
        node2.parentNode.removeChild(node2)

      selection.removeAllRanges()
      selection.addRange(range, backwards)

   
    @getRange = () ->
      start = 0
      end = 0

      # save selection
      selection.refresh()
      ranges = selection.getAllRanges()

      if ranges.length == 0
        console.warn('no available selection or cursor')
        return null

      range = ranges[0]
      backwards = selection.isBackwards()
      collapsed = selection.isCollapsed

      if !collapsed and backwards
        range4 = range.cloneRange()
        range4.collapse(false)
        endNode = document.createElement('a')
        endNode.setAttribute('class', 'rangeEnd')
        range4.insertNode(endNode)

      # insert node   [[inserted]      ]
      range2 = range.cloneRange()
      startNode = document.createElement('a')
      startNode.setAttribute('class', 'rangeStart')
      range2.insertNode(startNode)
      # get the position with innerHTML
      start = textfield.html().search('<a class="rangeStart"')
      # remove node
      startNode.parentNode.removeChild(startNode)

      selection.refresh()
      range = selection.getAllRanges()[0]

      if !collapsed and backwards
        selection.removeAllRanges()
        range.setEndBefore(endNode)
        endNode.parentNode.removeChild(endNode)
        selection.addRange(range,backwards)

      if collapsed
        end = start
      else
        # insert node at the end
        endNode = document.createElement('a')
        endNode.setAttribute('class', 'rangeEnd')
        range3 = range.cloneRange()
        range3.collapse(false)  # collapse to end
        range3.insertNode(endNode)

        # get the position with innerHTML
        end = $(textfield).html().search('<a class="rangeEnd"')
        # remove node
        endNode.parentNode.removeChild(endNode)
        selection.refresh()
        range = selection.getAllRanges()[0]

      # restore selection
      selection.removeAllRanges()
      selection.addRange(range, backwards)
      
      [start, end, textfield.html().length]

    @detectChangeAndUpdate = () =>
      oldText = @savedText

      currentRange = @getRange()

      if not currentRange
        return

      if !savedRange or savedRange[0] != currentRange[0] or savedRange[1] != currentRange[1]
        #console.log('selection changed', savedRange, "->", currentRange)
        savedRange = currentRange

      if @savedText != $(textfield).html()
        #console.log("change detected: \"" + @savedText, "\",\"" + textfield.html() + "\"")
        @savedText = $(textfield).html()
        operation = detectOperation(oldText, @savedText, savedRange)
        @msgId++
        operation.msgId = @msgId
        @pending.push(operation)
        wallSocket.sendAction({action:"alterText", timestamp:@timestamp, params:{id:@id, operations:@pending}})
        #for test: #wallSocket.sendActionDelayed({action:"alterText", timestamp:@timestamp, params:{id:@id, operations:@pending}}, 2000)

    # activate focus event handlers:
    $(textfield).focusin ()=>
      savedRange = @getRange()
      intervalId = setInterval(@detectChangeAndUpdate, 8000)

      # deactivate when focused out
      deactivate = ()=>
        @detectChangeAndUpdate() # check change for the last time
        clearInterval(intervalId)
        textfield.off 'focusout', deactivate
        $(textfield).get(0).normalize()
        #@setRange(0, textfield.html().length)

      $(textfield).on 'focusout', deactivate

    # activate key event handlers
    #$(textfield).on 'keyup', (e)=>
    #  console.log('[TEXT]', "keyup - keyCode: #{e.keyCode} charCode: #{e.charCode} which: #{e.which}", e)
      
    # activate key event handlers
    $(textfield).on 'keypress', (e)=>
      #console.log('[TEXT]', "keypress - keyCode: #{e.keyCode} charCode: #{e.charCode} which: #{e.which}", e)
      @detectChangeAndUpdate()


    # check for any update by the browser
    $(()=>
        setTimeout @detectChangeAndUpdate, 200
    )


  attachHandler: ->
    @handler = new TextSheetHandler(this)


  alterText: (operation, isMine, timestamp) ->
    # save current cursor and text
    # if it differs from last one, create new operation?
    # apply my change list => set text
    # restore cursor
    @detectChangeAndUpdate()
    @timestamp = timestamp

    range = @getRange()
    if not range
      range = [0,0,0]

    if isMine
      console.log("mine came (#{timestamp})")
      if @pending.length > 0 and @pending[0].msgId == operation.msgId
        #console.log("received mine")
        head = @pending.shift()
        @baseText = spliceString(@baseText, head.from, head.length, head.content)
      else if @pending.length > 0
        console.error("unexpected msgId came: #{operation.msgId} expected: #{@pending[0].msgId}, timestamp:#{timestamp}")
      else
        console.error("unexpected msgId came: #{operation.msgId}, timestamp:#{timestamp}")
    else
      original = @baseText

      ss = new StringWithState(@baseText)
      tmp = ss.apply(operation, 0)
      
      @baseText = spliceString(@baseText, operation.from, operation.length, operation.content)
      
      @pending = for p in @pending
        $.extend(ss.apply(p, 1), {msgId:p.msgId})
    
      rangeop = []
      len = range[2]

      ss2 = ss.clone()
      ss3 = ss.clone()

      rangeop[0] = new Operation(range[0], 0, "")
      rangeop[1] = new Operation(range[1], 0, "")
      
      range[0] = ss2.apply(rangeop[0], 1).from
      range[1] = ss3.apply(rangeop[1], 1).from
      
      html = @baseText

      # apply each operation in pending      
      for p in @pending
        #console.log("action:",action)
        html = spliceString(html, p.from, p.length, p.content)

      #console.log("other came (#{timestamp}). base:", original, " altered:", html, " pending:", @pending)
      
      @textfield.html(html)
      @savedText = @textfield.html()
      #console.log(range)
      @setRange(range[0], range[1])

  
