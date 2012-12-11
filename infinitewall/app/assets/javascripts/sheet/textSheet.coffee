
$(
  ()->
    rangy.init()
)


textTemplate = "
  <div class='sheetBox' tabindex='-1'>
    <div class='sheet' contentType='text'>
      <div class='sheetTopBar'>
        <a class = 'boxClose'>x</a>
        <h1 class='sheetTitle' contenteditable='true'> New Sheet </h1>
      </div>
      <div class='sheetText'>
        <div class='sheetTextField' contenteditable='true'>
        </div>
      </div>
      <div class='resizeHandle'></div>
    </div>
  </div>"

class Operation
    constructor: (@from, @length, @content) ->
 


class CharWithState
    constructor: (@c, @insertedBy = {}, @deletedBy = {}) ->

        
    setDeletedBy: (branch) ->
        @deletedBy[branch] = true
    setInsertedBy: (branch) ->
        @insertedBy[branch] = true
    
    
class StringWithState
    constructor:(str)->
        i = 0
        @list = []
        while i < str.length
            @list.push(new CharWithState(str.charAt(i)))
            i++

    apply:(op, branch) ->
        i = 0
        iBranch = 0
        insertPos = 0
        alteredFrom = 0
        numDeleted = 0

        @list = for cs in @list
            if !cs.deletedBy[branch] && (Object.keys(cs.insertedBy).length == 0 || cs.insertedBy[branch])
                if iBranch >= op.from && iBranch < op.from + op.length
                    if Object.keys(cs.deletedBy).length == 0
                        numDeleted++
                    cs.deletedBy[branch] = true
                else if iBranch == op.from + op.length
                    insertPos = i
                iBranch++
            i++
            cs

        inserted = for c in op.content
            insertedBy = {}
            insertedBy[branch] = true
            new CharWithState(c, insertedBy)
        
        i = 0
        for cs in @list
            if i < insertPos
                if Object.keys(cs.deletedBy).length == 0
                    alteredFrom++
            i++

        @list = @list.slice(0, insertPos).concat(inserted).concat(@list.slice(insertPos))
        new Operation(alteredFrom, numDeleted, op.content)



    text:() ->
        text = ""
        i = 0
        while i < @list.length
            cs = @list[i]
            if Object.keys(cs.deletedBy).length == 0
                text += cs.c
            i++
        text

    html:() ->
        html = ""
        i = 0
        while i < @list.length
            cs = @list[i]
            classes = []
            if Object.keys(cs.deletedBy).length > 0
                classes.push('deleted')
            if Object.keys(cs.insertedBy).length > 0
                classes.push('inserted')
            # if cs.deletedBy[A] || cs.deletedByA
            #     classes.push('A')
            # if cs.insertedByB || cs.deletedByB
            #     classes.push('B')

            if classes.length > 0
                html += "<span class='#{classes.join(' ')}'>#{cs.c}</span>"
            else
                html += cs.c

            i++

        html
                   

spliceString = (str, offset, remove, add) ->
  console.log("*", str.substr(0,offset),"*", (if add? then add else ""),"*",str.substr(Math.max(0,offset+remove)))
  str.substr(0,offset) + (if add? then add else "") + str.substr(Math.max(0, offset+remove))


updateRange = (range, actionSet) ->
 
  start = range[0]
  end = range[1]
 
  totalLength = 0
  i = 0
  while i < actionSet.length
    elem = actionSet[i]
    
    #element
    from = elem.from
    length = elem.length
    content = elem.content
    
    #if(type != 'replace') continue;
    if from >= 0 and length is 0 and content isnt "" # add action
      #console.log "ADDDDDD[from: " + elem.from + ", length: " + length + ", content: " + content + "]"
      contentLength = content.length
      totalLength += contentLength
      #result = result.substr(0, from) + content + result.substr(from, result.length)

      if start is 0 and end is 0

      
      # nothing
      else if start is 0 and end isnt 0
        if start is from and from < end
          start += contentLength
          end += contentLength
        else end += contentLength  if start < from and from < end
      else if end is totalLength
        if start is end

        
        #nothing
        else if start >= from
          start += contentLength
          end += contentLength
        else end += contentLength  if start < from and from < end
      else if start > 0 and start is end
        if start >= from
          start += contentLength
          end += contentLength
      else if start > 0 and start < end
        if start >= from
          start += contentLength
          end += contentLength
        else end += contentLength  if start < from and from < end
    else if from >= 0 and length > 0 and content is "" # remove
      #console.log "REMOVEE[applied: " + applied + ", from: " + elem.from + ", length: " + length + ", content: " + content + "]"
      contentLength = content.length
      totalLength -= length
      #result = result.substr(0, from) + result.substr(from + length, result.length)
      if start is 0 and end is 0

      
      # nothing
      else if from < start
        if from + length <= start
          start -= length
          end -= length
        else if from + length >= end
          start = from
          end = from
        else
          start = from
          end -= length
      else if start <= from
        if from + length < end
          end -= length
        else
          end = from
      else
    
    # nothing
    else if from >= 0 and length > 0 and content isnt "" # replace
      #console.log "REPLACE[applied: " + applied + ", from: " + elem.from + ", length: " + length + ", content: " + content + "]"
      contentLength = content.length
      totalLength -= length - contentLength
      #result = result.substr(0, from) + content + result.substr(from + length, result.length)
      if start is 0 and end is 0

      
      # nothing
      else if from < start
        if from + length <= start
          start -= length - contentLength
          end -= length - contentLength
        else if from + length >= end
          start = from + contentLength
          end = from + contentLength
        else
          start = from + contentLength
          end -= length - contentLength
      else if start <= from
        if from + length < end
          end -= length - contentLength
        else
          end = from + contentLength
      else
    
    # nothing
    else
      console.error "not proper action"
    i++

  [start,end]

detectOperation = (old, current, range) ->

  # add
  # delete
  # replace

  range[0] = if range[0] > 0 then range[0] else 0
  range[1] = if range[1] > 0 then range[1] else 0
  range[0] = if range[0] < current.length then range[0] else current.length-1
  range[1] = if range[1] < current.length then range[1] else current.length-1

  heuristic = ()->
    # there is no range. meaing we need heuristics to detect change
    cursor = range[1]
    cursor2 = if cursor > 0 then cursor-1 else 0
    console.log(cursor)

    # make sure Xend < cursor
    Xend = -1

    i = 0
    while i < cursor2 and i < old.length and i < current.length
      if current.charCodeAt(i) == old.charCodeAt(i)
        Xend = i
      else
        break
      i++

    ZstartAtCurrent = current.length
    ZstartAtOld = old.length
    
    #make sure cursor <= Zstart

    i = current.length - 1
    j = old.length - 1
    while i >= cursor2 and j >= cursor2
      if current.charCodeAt(i) == old.charCodeAt(j)
        ZstartAtCurrent = i
        ZstartAtOld = j
      else
        break
      i--
      j--

    # console.log('old:', old.length, old)
    # console.log('current:', current.length, current)
    # console.log("r:", range)
    # console.log("Xend:", Xend, ",Zstart(old):", ZstartAtOld, ",Zstart(cur):", ZstartAtCurrent, "added:", current.substr(Xend+1, ZstartAtCurrent-Xend-1))

    if spliceString(old, Xend+1, ZstartAtOld-Xend-1, current.substr(Xend+1, ZstartAtCurrent-Xend-1)) != current
      console.warn spliceString(old, Xend+1, ZstartAtOld-Xend-1, current.substr(Xend+1, ZstartAtCurrent-Xend-1)), current
      throw "operation error"

    {from: Xend+1, length: ZstartAtOld-Xend-1, content: current.substr(Xend+1,ZstartAtCurrent-Xend-1), range: [cursor,cursor]}


  if range[1] == range[0]
    heuristic()
  else
    # there is range, meaning the person did undo/redo. clearly the difference is in the range
    # case 1: replaced selection & undo
    # case 2: deleted selection & undo
    if range[0] > range[1]
      rangeEnd = range[0]
      rangeBegin = range[1]
    else
      rangeEnd = range[1]
      rangeBegin = range[0]

    diffBegin = rangeBegin
    diffEnd = old.length - (current.length - rangeEnd)

    if current.substr(0, diffBegin) != old.substr(0,diffBegin) or current.substr(rangeEnd) != old.substr(diffEnd)
      console.error('something is wrong with the text change. Falling back to heuristics')
      heuristic()
    else
      {from: diffBegin, length: diffEnd-diffBegin, content: current.substr(diffBegin, rangeEnd - rangeBegin), range: range}


class window.TextSheet extends Sheet
  @create: (content) ->
    x = Math.random() * ($(window).width() - 225) * 0.9 / glob.zoomLevel - (glob.scaleLayerXPos + (parseInt ($('#moveLayer').css 'x')) * glob.zoomLevel) / glob.zoomLevel
    y = Math.random() * ($(window).height() - 74) * 0.9 / glob.zoomLevel - (glob.scaleLayerYPos + (parseInt ($('#moveLayer').css 'y')) * glob.zoomLevel) / glob.zoomLevel
    w = 300
    h = 300

    title = "Untitled Text"

    wallSocket.send({action:"create", params:{x:x, y:y, width:w, height:h, title:title, contentType:"text", content:content}})

  setElement: () ->
    @element = $($(textTemplate).appendTo('#sheetLayer'))

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
        return [-1,-1]

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
      
      [start, end]

    @detectChangeAndUpdate = () =>
      oldText = @savedText

      currentRange = @getRange()

      if !savedRange or savedRange[0] != currentRange[0] or savedRange[1] != currentRange[1]
        #console.log('selection changed', savedRange, "->", currentRange)
        savedRange = currentRange

      if @savedText != $(textfield).html()
        console.log("change detected: \"" + @savedText, "\",\"" + textfield.html() + "\"")
        @savedText = $(textfield).html()
        operation = detectOperation(oldText, @savedText, savedRange)
        @msgId++
        operation.msgId = @msgId
        @pending.push(operation)
        wallSocket.send({action:"alterText", timestamp:@timestamp, params:{id:@id, operations:@pending}})
        #for test: #wallSocket.sendDelayed({action:"alterText", timestamp:@timestamp, params:{id:@id, operations:@pending}}, 2000)

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
        @setRange(0, textfield.html().length)

      $(textfield).on 'focusout', deactivate

    # activate key event handlers
    $(textfield).on 'keyup', ()=>
      @detectChangeAndUpdate()

    # check for any update by the browser
    $(()=>
        setTimeout @detectChangeAndUpdate, 200
    )


  attachHandler: () ->
    @handler = new TextSheetHandler(this)


  alterText: (operation, isMine, timestamp) ->
    # save current cursor and text
    # if it differs from last one, create new operation?
    # apply my change list => set text
    # restore cursor
    @detectChangeAndUpdate()
    @timestamp = timestamp

    range = @getRange()
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
      ss.apply(operation, 0)

      @baseText = spliceString(@baseText, operation.from, operation.length, operation.content)

      @pending = for p in @pending
        $.extend(ss.apply(p, 1), {msgId:p.msgId})

      range = updateRange(range, @pending)

      html = @baseText

      # apply each operation in pending      
      for p in @pending
        #console.log("action:",action)
        html = spliceString(html, p.from, p.length, p.content)

      console.log("other came (#{timestamp}). base:", original, " altered:", html, " pending:", @pending)
      
      @textfield.html(html)
      @savedText = @textfield.html()
      #console.log(range)
      #@setRange(range)

  
