class Operation
  constructor: (@position, @numRemove, @insertStr, @range) ->


detectOperation = (old, current, range) ->
  if range[1] == range[0]
    # there is no range. meaing we need heuristics to detect change
    cursor = range[0]
    i = 0
    diffBegin = cursor
    diffEnd = old.length - (current.length - cursor)
    while i < cursor and i < old.length
      if current.charCodeAt(i) != old.charCodeAt(i)
        diffBegin = i
        break
      i +=1

    new Operation(diffBegin, diffEnd - diffBegin, current.substr(diffBegin, cursor - diffBegin), [cursor, cursor])
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

    new Operation(diffBegin, diffEnd - diffBegin, current.substr(diffBegin, rangeEnd - rangeBegin), range)

class WallSocket extends window.EventDispatcher
  constructor: (url) ->
    super
    @unreceivedMine = [] # {basetimestamp, userid, original change, }
    @timestamp = 999
    @sentTimestamp = 999
    @receivedTimestamp = 999
    WS = if window['MozWebSocket'] then MozWebSocket else WebSocket
    socket = new WS(url)

    @send = (msg) ->
      socket.send(JSON.stringify(msg))

    @close = () =>
      socket.close

    onReceive = (e) =>
      data = JSON.parse(e.data)
      
      if data.error
        console.log('disconnected: ' + data.error)
        socket.close()
        return

      # assert: @receivedTimestamp < data.timestamp
      @receivedTimestamp = data.timestamp
      
      if data.kind == "action" and @timestamp < @receivedTimestamp
        # rebase if not mine, collapse if mine
        @synchronize(data)
        detail = JSON.parse(data.detail)
        @trigger('receive', detail)
        @timestamp = data.timestamp;

    onError = (e) =>
      console.log("error", e)
      @trigger('error', e)

    onClose = (e) =>
      console.log("close", e)
      @trigger('close', e)
        
    socket.onmessage = onReceive
    socket.onerror = onError
    socket.onclose = onClose

  synchronize: (data) ->
    # check in unreceivedMine for new entry =>
      # if mine, remove
      # if not mine, update change 

window.WallSocket = WallSocket
window.detectOperation = detectOperation
