define ["jquery", "./util", "./operation", "./stringwithstate" ], ($, TextUtil, Operation, StringWithState) ->

	# action: operation with range

	class Log
		constructor:(@action, @isMine) ->


	class TextHistory
		constructor: (@baseText, @timestamp) ->
			@msgId = 0
			@log = []
			@pending = []
			@cursor = 0
			@pendingPos = 0

		getPending:()->
			@pending

		hasPending:()->
			@pending.length > 0

		getPendingMsgId:()->
			@pending[0].msgId

		# add to pending and log and remove all undone records in log
		write: (action, undoStr) ->
			# add to pending
			@pending.push(action)
			@msgId += 1

			# remove all 'mine' records behind cursor
			i = @cursor
			while i < @log.length
				if @log[i].isMine
					@log.splice(i,1) # remove(i)
				else
					i = i + 1

			# write operation to log tail
			@log.push(new Log(action, true))
			@cursor += 1

			@msgId

		undo:(range) ->
			if @cursor <= 0
				throw 'undo: cursor <= 0'

			action = @getUndoAction()

			[newText, unused, newRange] = @merge(@baseText, [], action, range)
			@baseText = alteredText

			#add to @pending
			@pending.push(undoAction)
			@cursor -= 1

			[@baseText, newRange]

		redo:(range) ->
			if @cursor >= @log.length
				throw 'redo: cursor >= length'

			action = @getRedoAction()

			[newText, unused, newRange] = @merge(@baseText, [], action, range)
			@baseText = alteredText

			#add to @pending
			@pending.push(undoAction)
			@cursor += 1

			[@baseText, newRange]

		getUndoAction: () ->
			if @cursor <= 0
				throw 'invalid operation'
			
			action = @log[@cursor-1].action
			undoAction = new Operation(action.from, action.content.length, @log[@cursor-1].undoStr)
			# recompute undoAction based on consolidated other's records
			# 1. get baseText towards undo position by rolling back other's records
			i = @log.length-1
			baseText = @baseText
			others = []

			_(@log.slice(@cursor-1, @log.length)).filter((log) -> not log.isMine).map (log) ->
				a = log.action
				others.push(a)
				u = new Operation(a.from, a.content.length, log.undoStr)
				baseText = spliceString(baseText, u.from, u.length, u.content)

			# 2. merge the undo action with all other's records, applying forward
			ss = new StringWithState(baseText)
			for other in others
				ss.apply(other, 1)

			undoAction = ss.apply(undoAction, 0)
			
			undoAction

		getRedoAction: () ->
			if @cursor >= @log.length
				throw 'invalid operation'

			@log[@cursor].action

		merge:(baseText, pending, operation, range) ->
			ss = new StringWithState(baseText)

			ss.apply(operation, 0)
			newPending = for p in pending
				$.extend(ss.apply(p, 1), {msgId:p.msgId})
			
			newText = ss.text()

			# for range calculation
			ss2 = ss.clone()
			ss3 = ss.clone()

			# find where the selection range is by applying in to the string
			rangeop = [new Operation(range[0], 0, ""), new Operation(range[1], 0, "")]
			newRange = [ss2.apply(rangeop[0], 1).from, ss3.apply(rangeop[1], 1).from]
			
			[newText, newPending, newRange]

		consolidateMine: (operation) ->
			# check validity
			if @pending.length > 0 and @pending[0].msgId == operation.msgId
				# remove received bit from @pending, as it is no longer used
				head = @pending.shift()
				# new base text
				@baseText = TextUtil.spliceString(@baseText, head.from, head.length, head.content)
				
				true
			else
				false

		consolidateOther:(operation, range) ->
						
			# get new baseText applying new operation
			undoStr = @baseText.substr(operation.from, operation.length)
			
			[newText, newPending, newRange] = @merge(@baseText, @pending, operation, range)
			@baseText = newText
			@pending = newPending
				
			# write as log with undoStr
			@log.push(new Log(operation, undoStr, false))

			[@baseText, newRange]

