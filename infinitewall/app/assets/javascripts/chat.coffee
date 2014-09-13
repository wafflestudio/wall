define ["jquery", "EventDispatcher", "websocket"], ($, EventDispatcher, PersistentWebsocket) ->
  class Chat extends EventDispatcher
    
    constructor: (pwebsocket, urls, chatRoomId, timestamp) ->
      super()
      @scope = "chat/#{chatRoomId}"
      @socket = pwebsocket.join(@scope, timestamp)
      
      @chatWindow = $('#chatWindow')
      @chatLog = $('#chatLog')
      @userList = $('#chatUsers')
      @chatInput = $('#chatInput')
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
          @refreshUserList()
      
          if not @ready
            @connectionId = data.connectionId
            console.log(@scope, 'chat connected with connection id ' + @connectionId)
            # now sending message is available
            @chatInput.on 'keydown', (event) =>
              if event.keyCode is 13 and !event.shiftKey and @chatInput.val().replace(/\s/g, '').length > 0
                @sendCurrentMessage()

          @ready = true

        when "join"
          @addConnection(data)
          @refreshUserList()

        when "quit"
          @removeConnection(data)
          @refreshUserList()

        when "talk" then newMessage = @messageHtml(@users[data.email] || {email: data.email, nickname: data.nickname, userId:data.userId}, data.message)
        
      @chatLog.append newMessage if newMessage?
      @chatLog.clearQueue()
      @chatLog.animate {scrollTop : @chatLog.prop('scrollHeight') - @chatLog.height()}, 150
    
    sendCurrentMessage: ->
      msg = {}
      text = @chatInput.val()
      #text = msg.substr(0, msg.length - 1) if msg.charAt(msg.length - 1) is '\n'
      
      msg.path = @scope
      msg.timestamp = @timestamp unless msg.timestamp?
      msg.uuid = @uuid
      msg.connectionId = @connectionId
      msg.text = text
      msg.type = "talk"

      @chatInput.val("")
      @socket.send JSON.stringify(msg)

    close: ->
      console.log('close called')
      @socket.close()

    toggle: -> @chatWindow.fadeToggle()

    setUsers: (users) ->
      # clear all existing users
      @users = {}
      
      for user in users
        @users[user.email] ||= user
        @users[user.email].sessionCount ||= 0
        @users[user.email].sessionCount += 1
      
      
    addConnection: (data) ->
      detail = JSON.parse(data.message)
      numConnections = detail.numConnections
        
      if numConnections == 1
        @users[data.email] = {userId:data.userId, email: data.email, nickname: data.nickname || detail.nickname}
        newMessage = @infoHtml(data.nickname || detail.nickname , " has joined")
      else
        newMessage = @infoHtml(data.nickname || detail.nickname, " added new connection")

      if not @users[data.email]?
        @users[data.email] = {userId:data.userId, email: data.email, nickname: data.nickname || detail.nickname}
      
      if @ready
        @users[data.email].sessionCount = numConnections

    removeConnection: (data) ->
      detail = JSON.parse(data.message)
      numConnections = detail.numConnections

      if not @users[data.email]?
        @users[data.email] = {userId:data.userId, email: data.email, nickname: data.nickname || detail.nickname}
        
      if numConnections == 0
        newMessage = @infoHtml(@users[data.email].nickname || detail.nickname, " has left")
      else
        newMessage = @infoHtml(@users[data.email].nickname || detail.nickname, " removed a connection")

        if @ready
          @users[data.email].sessionCount = numConnections

    refreshUserList: () ->
      @userList.html('')
      #console.log("[CHAT]", @users)
      for email,user of @users
        @userList.append $("<div class = 'chatProfilePic' style = 'background-image:url(/users/#{user.userId}/profile)'> <div class = 'chatNickname'>#{user.nickname}</div> </div>")

    getUserInfo: () ->
      $.getJSON("/")

    messageHtml: (user, message) ->
      owner = if user?.email is stage.currentUser then "isMine" else "isNotMine"
      $("<div class = 'messageContainer'>
          <div class = 'messageDiv #{owner}'>
            <div class = 'messageProfilePicContainer'>
              <div class = 'messageProfilePic' data-userid ='#{user.email}' style = 'background-image:url(/users/#{user.userId}/profile)'></div>
            </div>
            <div class = 'messageRest'>
              <div class = 'messageNickname'>#{user?.nickname ? "???"}</div>
              <span class = 'messageText'>#{message}</span>
            </div>
          </div>
        </div>")

    infoHtml: (who, message) ->
      $("<div class = 'infoContainer'>
          <div class = 'infoMessage'>
            <span class = 'infoWho'>#{who}</span>
            <span class = 'infoMessage'>#{message}</span>
          </div>
        </div>")
