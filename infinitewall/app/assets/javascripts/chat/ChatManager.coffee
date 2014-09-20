define ["./chat", "common/EventDispatcher"], (Chat, EventDispatcher) ->

	class ChatManager extends EventDispatcher
		constructor: (pwebsocket, urls, chatRoomId, timestamp) ->
			super()

			@chat = new Chat(pwebsocket, urls, chatRoomId, timestamp)

			@chatWindow = $('#chatWindow')
			@chatLog = $('#chatLog')
			@userList = $('#chatUsers')
			@chatInput = $('#chatInput')

			@chat.on 'ready', () =>
				@chatInput.on 'keydown', (event) =>
					if event.keyCode is 13 and !event.shiftKey and @chatInput.val().replace(/\s/g, '').length > 0
						@chat.sendMessage(@chatInput.val())
						@chatInput.val("")

			@chat.on 'refreshUsers', (users) =>
				@userList.html('')
				for email,user of users
					@userList.append $("<div class = 'chatProfilePic' style = 'background-image:url(/users/#{user.userId}/profile)'> <div class = 'chatNickname'>#{user.nickname}</div> </div>")
					
			@chat.on 'talk', (e) =>
				newMessage = @messageHtml({email: e.email, nickname: e.nickname, userId:e.userId}, e.message)
				@updateLog(newMessage)

			@chat.on 'userEnter', (e) =>
				newMessage = @infoHtml(e.nickname || e.nickname , " has joined")
				@updateLog(newMessage)

			@chat.on 'userLeave', (e) =>
				newMessage = @infoHtml(e.nickname, " has left")
				@updateLog(newMessage)

			@chat.on 'userAddConnection', (e) =>
				newMessage = @infoHtml(e.nickname, " added new connection")
				@updateLog(newMessage)

			@chat.on 'userRemoveConnection', (e) =>
				newMessage = @infoHtml(e.nickname, " removed a connection")
				@updateLog(newMessage)

		toggle: -> 
			@chatWindow.fadeToggle()

		updateLog: (html) =>
			@chatLog.append html
			@chatLog.clearQueue()
			@chatLog.animate {scrollTop : @chatLog.prop('scrollHeight') - @chatLog.height()}, 150      		

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
			$("""<div class = 'infoContainer'>
				<div class = 'infoMessage'>
					<span class = 'infoWho'>#{who}</span>
					<span class = 'infoMessage'>#{message}</span>
				</div>
			</div>""")


      	
