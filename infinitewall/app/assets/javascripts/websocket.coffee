# required for extending:
# @timestamp
# @url
# @scope


class window.PersistentWebsocket extends EventDispatcher
  

  constructor: (@url, scope = "WS", @timestamp) ->
    super()
    @WS = if window['MozWebSocket'] then MozWebSocket else WebSocket
    @status = "TRYING"
    @numRetry = 0
    @scope = "[#{scope}]"
    @buffer = [] # emergency buffer

    @connect()

  isConnected:() ->
    @status == "CONNECTED"

  connect: ()=>
    console.info(@scope, "Retrying to connect... ", @numRetry, "ts: #{@timestamp}") if @numRetry > 0 
    @socket = new @WS(@url + if @timestamp? then "?timestamp=#{@timestamp}" else "")
    @socket.onopen = @onOpen
    @socket.onerror = @onError
    @socket.onclose = @onClose


  send: (msg) ->
    if @isConnected()
      @socket.send(msg)
      console.info(@scope, "sending #{msg.length} characters", msg)
    else
      @buffer.push(msg)

  close: ()->
    @socket.close()


  # @override
  onReceive: (e) =>
    data = JSON.parse(e.data)
    console.log(@scope, data)

  onOpen: (e) =>
    
    if @buffer.length > 0
      console.info(@scope, "sending #{@buffer.length} pending messages")
      while @buffer.length > 0
        @socket.send(@buffer[0])
        @buffer.shift()

    @socket.onmessage = @onReceive
    console.info(@scope, "connection established: ", e)
    @trigger('open', e)
    @status = "CONNECTED"
    @numRetry = 0
      

  onClose: (e) =>
    @status = "TRYING"
   
    @socket.onclose = null
    @socket.onopen = null
    @socket.onmessage = null
    @socket.onerror = null

    setTimeout(@connect, Math.pow(2, @numRetry) * 1000)
    @numRetry += 1 if @numRetry < 5
    console.warn(@scope, "connection closed: ", e, "Will retry connect")
    @trigger('close', e)

  onError: (e) =>
    if @status == "TRYING"
      console.warn(@scope, "cannot establish connnection: ", e)
      #setTimeout(@connect, Math.pow(2, @numRetry) * 1000) 
      #@numRetry += 1 if @numRetry < 5
    else
      console.error(@scope, "chat connection caught error: ", e)

    @trigger('error', e)