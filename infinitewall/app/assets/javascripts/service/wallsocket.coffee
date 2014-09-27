define ["common/EventDispatcher", "jquery", "./websocket"], (EventDispatcher, $, PersistentWebsocket) ->
  class WallSocket extends EventDispatcher


    constructor: (pwebsocket, wallId, timestamp) ->
      super()

      @scope = "wall/#{wallId}"
      @socket = pwebsocket.join(@scope, timestamp)
      @uuid = pwebsocket.uuid
      @receivedTimestamp = timestamp
      @timestamp = timestamp
      @pending = []
      
      console.info(@scope, "wall socket initialized to UUID: #{@uuid} ts:#{timestamp}")
      @socket.on 'receive', @onReceive
      @on 'receivedAction', @onReceivedAction

      @socket.on 'open', () =>
        console.log(@scope, 'connection established')

      @socket.on 'close', () =>
        console.log(@scope, 'connection closed')
    
    sendAction: (msg, historyData) ->
      msg.path = @scope
      #console.log(msg)
      msg.type = "action"
      msg.timestamp = @timestamp unless msg.timestamp?
      msg.uuid = @uuid
      @pending.push(msg)
      @socket.send(JSON.stringify(msg))

      if historyData?
        historyData.uuid = msg.uuid
        historyData.timestamp = msg.timestamp
        console.log(historyData)
        stage.history.push({from: historyData, to: msg})

    sendUndoAction: (msg, historyData) ->
      msg.path = @scope
      msg.type = "action"
      msg.timestamp = historyData.timestamp = @timestamp
      msg.uuid = historyData.uuid = @uuid
      @pending.push(msg)
      @socket.send(JSON.stringify(msg))
      {from: historyData, to: msg}

    sendRedoAction: (msg, historyData) ->
      msg.path = @scope
      msg.type = "action"
      msg.timestamp = historyData.timestamp = @timestamp
      msg.uuid = historyData.uuid = @uuid
      @pending.push(msg)
      @socket.send(JSON.stringify(msg))
      {from: historyData, to: msg}

    sendAck: () ->
      msg = {action:'ack', type:'action'}
      msg.path = @scope
      msg.timestamp = @timestamp unless msg.timestamp?
      msg.uuid = @uuid
      @socket.send(JSON.stringify(msg))

    # only for debug
    sendActionDelayed: (msg, delay) ->
      msg.path = @scope
      msg.type = "action"
      msg.timestamp = @timestamp unless msg.timestamp?
      msg.uuid = @uuid
      json = JSON.stringify(msg)
      console.log(@scope, "will send:" + json)
      setTimeout (=> @sendAction(json)), delay

    onReceive: (data) =>
      console.info(@scope, 'received:', data)

      @receivedTimestamp = data.timestamp

      if data.error
        console.log(@scope, 'Error: ' + data.error)
        if @socket.isConnected()
          @socket.numRetry = 10
          @socket.close()
        return

      while @pending.length > 0 and @pending[@pending.length-1].timestamp <= @receivedTimestamp
        @pending.pop()
      
      if data.kind is "action" and (not @timestamp? or @timestamp < @receivedTimestamp)
        @timestamp = data.timestamp
        detail = JSON.parse(data.detail)
        @trigger('receivedAction', detail, detail.uuid == @uuid, data.timestamp)
        @sendAck()
      else if data.kind is "action"
        console.warn(@scope, "received message with older timestamp: #{data.timestamp} < #{@timestamp}")
      else if data.kind is "welcome"
        console.info('joined successfully')
        

    onReceivedAction: (detail, isMine, timestamp) =>
      isMine = isMine || false
      sheet = stage.sheets[detail.params.sheetId]

      switch detail.action
        when "alterText" then sheet.alterText(detail.params, isMine, timestamp)
        when "create" then stage.createSheet(detail.sheetId, detail.params, timestamp)
        when "move" then sheet.move(detail.params) unless isMine
        when "resize" then sheet.resize(detail.params) unless isMine
        when "remove" then sheet.remove(detail.params)
        when "setTitle" then sheet.setTitle(detail.params) unless isMine
        when "setLink" then sheet.setLink(detail.params)
        when "removeLink" then sheet.removeLink(detail.params)
        else console.error("Not supported action", detail)
