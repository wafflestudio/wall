class window.Chat
  users: {}

  constructor: (url) ->
    WS = if window['MozWebSocket'] then MozWebSocket else WebSocket
    @socket = new WS(url)
    @socket.onmessage = @onReceive
    @socket.onerror = @onError
    @socket.onclose = @onError
    @chatWindow = $('#chatWindow')
    @chatLog = $('#chatLog')
    @userList = $('#chatUsers')
    @chatInput = $('#chatInput')
    @chatInput.textareaAutoExpand()
    @connectionId = -1
    @status = "DISCONNECTED"

  toggle: -> @chatWindow.fadeToggle()

  sendMessage: =>
      msg = @chatInput.val()
      #msg = msg.substr(0, msg.length - 1) if msg.charAt(msg.length - 1) is '\n'
      @chatInput.val("")
      @socket.send JSON.stringify({connectionId:@connectionId, text: msg})

  onReceive: (e) =>
      data = JSON.parse(e.data)
      console.log data

      if data.error
        console.log('disconnected: ' + data.error)
        @socket.close()
        return

      switch data.kind
        when "welcome"
          @setUsers(data.users)
          @refreshUserList()

          if @status == "DISCONNECTED"
            @connectionId = data.connectionId
            console.log('connected with connection id ' + @connectionId)
            # now sending message is available
            @chatInput.on 'keydown', (event) =>
              if event.keyCode is 13 and !event.shiftKey and @chatInput.val().replace(/\s/g, '').length > 0
                @sendMessage()

          @status = "CONNECTED"

        when "join"
          @addConnection(data)
          @refreshUserList()

        when "quit"
          @removeConnection(data)
          @refreshUserList()
 
        when "talk" then newMessage = @messageHtml(@users[data.username], data.message)
        
      @chatLog.append newMessage if newMessage?
      @chatLog.animate {scrollTop : @chatLog.prop('scrollHeight') - @chatLog.height()}, 150
  
  onError: (e) ->
    # TODO: add reconnection
    console.log(e)

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
      @users[data.username] = {username: data.username, nickname: data.nickname || detail.nickname, picture: data.picture}
      newMessage = @infoHtml(data.nickname || detail.nickname , " has joined")
    else
      newMessage = @infoHtml(data.nickname || detail.nickname, " added new connection")

    if @status == "CONNECTED"
      @users[data.username].sessionCount = numConnections

  removeConnection: (data) ->
    detail = JSON.parse(data.message)
    numConnections = detail.numConnections
    if numConnections == 0
      newMessage = @infoHtml(@users[data.username].nickname || detail.nickname, " has left") 
      delete @users[data.username]
    else
      newMessage = @infoHtml(@users[data.username].nickname || detail.nickname, " removed a connection") 

    if @status == "CONNECTED"
      @users[data.username].sessionCount = numConnections

  refreshUserList: () ->
    @userList.html('')
    for email,user of @users
      @userList.append $("<div class = 'chatProfilePic' style = 'background-image:url(#{user.picture})'> </div>")

    $('.messageContainer .messageProfilePic').each (i, el) =>
      $(el).css('background-image', "url(#{@users[$(el).data('userid')].picture})")



  messageHtml: (user, message) ->
    owner = if user?.email is stage.currentUser then "isMine" else "isNotMine"
    $("<div class = 'messageContainer'>
        <div class = 'messageDiv #{owner}'>
          <div class = 'messageProfilePicContainer'>
            <div class = 'messageProfilePic' data-userid ='#{user.username}' style = 'background-image:url(#{user?.picture ? ""})'></div>
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

  #userQuit: (user) ->
    #if users[user.email].sessionCount is 1
      #delete users[user.email]
    #else
      #users[user.email].sessionCount--
