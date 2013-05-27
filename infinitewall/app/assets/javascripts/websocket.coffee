# required for extending:
# @timestamp
# @url
# @scope

# states: CONNECTED <=> TRYING

class window.PersistentWebsocket extends EventDispatcher
  
  constructor: (@url, scope = "WS", @timestamp) ->
    super()
    @WS = if window['MozWebSocket'] then MozWebSocket else WebSocket
    @status = "TRYING"
    @numRetry = 0
    @scope = "[#{scope}]"
    @buffered = [] # emergency buffer
    @pending = []

    @connect()

  isConnected:() ->
    @status == "CONNECTED"

  connect: ()=>
    console.info(@scope, "Retrying to connect... ", @numRetry, "ts: #{@timestamp}") if @numRetry > 0 
    @socket = new @WS(@url + if @timestamp? then "?timestamp=#{@timestamp}" else "")
    @socket.onopen = @onOpen
    @socket.onerror = @onError
    @socket.onclose = @onClose

  trySend: () ->

    checkAndSendLoop = () =>
      if @socket.readyState == @WS.OPEN and @socket.bufferedAmount == 0
        @buffered = []
        # fill buffer with new pending messages
        for msg in @pending
          @buffered.push(msg)
        #clear pending
        @pending = []

        for msg in @buffered
          @socket.send(msg)
        
      if @socket.readyState == @WS.OPEN and @buffered.length > 0
        setTimeout(checkAndSendLoop, 100)
      else
        @trySending = false

    @trySending = true
    checkAndSendLoop()

  send: (msg) ->
    @pending.push(msg) if msg
    if @isConnected
      @trySend()
    else 
      @trySendingHttp()
    
    console.info(@scope, "sending #{msg.length} characters", msg)

  close: ()->
    @socket.close()


  # @override
  onReceive: (e) =>
    data = JSON.parse(e.data)
    console.log(@scope, data)
    @trigger('receive', data)

  onOpen: (e) =>
    
    if @buffered.length > 0
      console.info(@scope, "sending #{@pending.length} unsent messages")
      for msg in @buffered
        @socket.send(msg)

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
    else
      console.error(@scope, "chat connection caught error: ", e)
    @trigger('error', e)
