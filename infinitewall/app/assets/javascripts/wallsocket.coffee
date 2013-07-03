define ["EventDispatcher", "jquery", "websocket", "cometsocket"], (EventDispatcher, $, PersistentWebsocket, CometSocket) ->
  class WallSocket extends EventDispatcher

    generateUUID: ->
      'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
        r = Math.random()*16|0
        v = if c == 'x' then r else (r&0x3|0x8)
        v.toString(16);
      ) + "-" + new Date().getTime().toString(36)

    constructor: (urls, timestamp) ->
      super()

      @uuid = @generateUUID()
      @websocket = new PersistentWebsocket(urls.websocket + "?uuid=#{@uuid}", "WALL", timestamp)
      @comet = new CometSocket(urls.speak + "?uuid=#{@uuid}", urls.listen + "?uuid=#{@uuid}", "COMET", timestamp)
      @receivedTimestamp = timestamp
      @timestamp = timestamp
      @scope = @websocket.scope
      @pending = []
      
      console.info(@scope, "wall socket initialized to UUID: #{@uuid} ts:#{timestamp}")
      @websocket.on 'receive', @onReceive
      @on 'receivedAction', @onReceivedAction
      @websocket.on 'open', () =>
        console.log(@scope, 'websocket established')
        @comet.deactivate()
        @comet.off 'receive', @onReceive

        if @pending.length > 0
          console.info(@scope, "sending #{@pending.length} unsent messages")
          for msg in @pending
            @websocket.send(JSON.stringify(msg))


      @websocket.on 'close', () =>
        console.log(@scope, 'websocket closed')
        @comet.activate()
        @comet.on 'receive', @onReceive
        if @pending.length > 0
          console.info(@scope, "sending #{@pending.length} unsent messages")
          for msg in @pending
            @comet.send(JSON.stringify(msg))
    
    sendAction: (msg, historyData) ->
      msg.timestamp = @timestamp unless msg.timestamp?
      msg.uuid = @uuid
      @pending.push(msg)
      if @websocket.isConnected()
        @websocket.send(JSON.stringify(msg))
      else
        @comet.send(JSON.stringify(msg))
      stage.history.push(historyData)

    sendAck: () ->
      msg = {action:'ack'}
      msg.timestamp = @timestamp unless msg.timestamp?
      msg.uuid = @uuid
      if @websocket.isConnected()
        @websocket.send(JSON.stringify(msg))
      else
        @comet.send(JSON.stringify(msg))

    # only for debug
    sendActionDelayed: (msg, delay) ->
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
        if @websocket.isConnected()
          @websocket.numRetry = 10
          @websocket.close()
        return

      while @pending.length > 0 and @pending[@pending.length-1].timestamp <= @receivedTimestamp
        @pending.pop()
      
      if data.kind is "action" and (not @timestamp? or @timestamp < @receivedTimestamp)
        @timestamp = data.timestamp
        @comet.timestamp = @timestamp
        detail = JSON.parse(data.detail)
        @trigger('receivedAction', detail, detail.uuid == @uuid, data.timestamp)
        @sendAck()
      else if data.kind is "action"
        console.warn(@scope, "received message with older timestamp: #{data.timestamp} < #{@timestamp}")
        

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
