class window.WallSocket extends window.PersistentWebsocket
  constructor: (url, timestamp) ->
    super(url, "WALL", timestamp)

    @receivedTimestamp = @timestamp
    @on 'receivedAction', @onReceivedAction
    console.info("wall socket initialized to ts:#{timestamp}")
  
  sendAction: (msg) ->
    msg.timestamp = @timestamp unless msg.timestamp?
    @send(JSON.stringify(msg))

  # only for debug
  sendActionDelayed: (msg, delay) ->
    msg.timestamp = @timestamp unless msg.timestamp?
    json = JSON.stringify(msg)
    console.log("will send:" + json)
    setTimeout (=> @sendAction(json)), delay


  onReceive: (e) =>
    data = JSON.parse(e.data)
    console.info('received:', data)
    @receivedTimestamp = data.timestamp

    if data.error
      console.log('disconnected: ' + data.error)
      @close()
      return
    
    if data.kind is "action" and @timestamp < @receivedTimestamp
      @timestamp = data.timestamp
      detail = JSON.parse(data.detail)
      @trigger('receivedAction', detail, data.mine, data.timestamp)
      @sendAction({action:'ack'})
      

  onReceivedAction: (detail, isMine, timestamp) =>
    isMine = isMine || false
    sheet = stage.sheets[detail.params.id]

    switch detail.action
      when "alterText" then sheet.alterText(detail.params, isMine, timestamp)
      when "create" then stage.createSheet(detail.id, detail.params, timestamp)
      when "move" then sheet.move(detail.params) unless isMine
      when "resize" then sheet.resize(detail.params) unless isMine
      when "remove" then sheet.remove(detail.params)
      when "setTitle" then sheet.setTitle(detail.params) unless isMine
      when "setLink" then sheet.setLink(detail.params)
      when "removeLink" then sheet.removeLink(detail.params)
