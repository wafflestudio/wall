define ["jquery", "common/EventDispatcher"], ($, EventDispatcher) ->
  class Chat extends EventDispatcher
    
    constructor: (pwebsocket, urls, chatRoomId, timestamp) ->
      super()
      @scope = "chat/#{chatRoomId}"
      @socket = pwebsocket.join(@scope, timestamp)
      @connectionId = -1
      @ready = false
      @users =  {}
      @socket.on 'receive', @onReceive

      # events
      #@on "open",=> @chatWindow.fadeTo(500, 1.0)
      #@on "close", => @chatWindow.fadeTo(500, 0.4)
    
    onReceive: (data) =>
      #console.log(@scope, data)
      @socket.timestamp = data.timestamp if data.timestamp?

      if data.error
        console.log(@scope, 'Disconnecting from an unknown error: ' + data.error)
        @close()
        return

      switch data.kind
        when "welcome"
          @setUsers(data.users)
      
          if not @ready
            @connectionId = data.connectionId
            console.log(@scope, 'chat connected with connection id ' + @connectionId)
            # now sending message is available
            @trigger('ready')

          @ready = true
          @trigger('refreshUsers', @users)

        when "join"
          @addConnection(data)
          @trigger('refreshUsers', @users)
          
        when "quit"
          @removeConnection(data)
          @trigger('refreshUsers', @users)
          
        when "talk" 
          @trigger('talk', {email: data.email, nickname: data.nickname, userId: data.userId, message: data.message})
    
    sendMessage: (text)->
      msg = {}
      #text = msg.substr(0, msg.length - 1) if msg.charAt(msg.length - 1) is '\n'
      
      msg.path = @scope
      msg.timestamp = @timestamp unless msg.timestamp?
      msg.uuid = @uuid
      msg.connectionId = @connectionId
      msg.text = text
      msg.type = "talk"

      @socket.send JSON.stringify(msg)

    close: ->
      console.log('close called')
      @socket.close()

    setUsers: (users) ->
      # clear all existing users
      @users = {}
      
      for user in users
        @users[user.email] ||= user
        @users[user.email].sessionCount ||= 0
        @users[user.email].sessionCount += 1
      
    addConnection: (data) ->
      console.log('addConnection', data)
      detail = JSON.parse(data.message)
      numConnections = detail.numConnections

      unless @users[data.email]?
        @users[data.email] = {userId:data.userId, email: data.email, nickname: data.nickname || detail.nickname}
        
      if numConnections == 0        
        @trigger('userEnter', {nickname: @users[data.email].nickname || detail.nickname})
      else
        @trigger('userAddConnection', {email:data.email, nickname: @users[data.email].nickname || detail.nickname})

      if not @users[data.email]?
        @users[data.email] = {userId:data.userId, email: data.email, nickname: data.nickname || detail.nickname}
      
      @users[data.email].sessionCount = numConnections

    removeConnection: (data) ->
      console.log('removeConnection')
      detail = JSON.parse(data.message)
      numConnections = detail.numConnections

      unless @users[data.email]?
        @users[data.email] = {userId:data.userId, email: data.email, nickname: data.nickname || detail.nickname}
        
      if numConnections == 0
        @trigger('userLeave', {nickname: @users[data.email].nickname || detail.nickname})
      else
        @trigger('userRemoveConnection', {nickname: @users[data.email].nickname || detail.nickname})

      @users[data.email].sessionCount = numConnections

