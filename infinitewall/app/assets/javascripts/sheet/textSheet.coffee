define [
	"jquery",
	"text/util",
	"text/operation",
	"text/stringwithstate",
	"rangeutil",
	"./sheet",
	"./textSheetHandler",
	"templatefactory",
	"rangy",
	"text/texthistory",
	"hallo"], ($, TextUtil, Operation, StringWithState, RangeUtil, Sheet, TextSheetHandler, TemplateFactory, rangy, TextHistory, hallo) ->


	class TextSheet extends Sheet
		@create: (content) ->
			x = Math.floor(Math.random() * ($(window).width() - 225) * 0.9 / stage.zoom - (stage.scaleLayerX + (parseInt ($('#moveLayer').css 'x')) * stage.zoom) / stage.zoom)
			y = Math.floor(Math.random() * ($(window).height() - 74) * 0.9 / stage.zoom - (stage.scaleLayerY + (parseInt ($('#moveLayer').css 'y')) * stage.zoom) / stage.zoom)
			w = 240
			h = 168
			title = "Untitled Text"

			action = {action:"create", params:{x:x, y:y, width:w, height:h, title:title, contentType:"text", content:content}}
			histObj = {action:"remove", params:{}}
			wallSocket.sendAction(action, histObj)

		setElement: ->
			textTemplate = TemplateFactory.makeTemplate("textSheet")
			@element = $($(textTemplate).appendTo('#sheetLayer'))
			
			@element.find(".sheetTextField").hallo({
				plugins:
					'halloformat' : {"bold": true, "italic": true, "strikethrough": true, "underline": false}
			})
			@innerElement = @element.children('.sheet')

		constructor: (params, timestamp) ->
			super(params)
			textfield = @element.find('.sheetTextField')
			@contentType = "textSheet"
			#textfield.on 'resize', (e) =>
				#if $(e.target).height() > @ih
					#@ih = $(e.target).height()
			@id = params.sheetId
			
			@textfield = textfield
			@element.find('.sheetTextField').html(params.content)
			@textfield.html(params.content)

			if @textfield.html() != params.content
				console.warn("browser altered content! :", @textfield.html(), ":", params.content)

			@history = new TextHistory(params.content, timestamp)
			@savedText = params.content # saved text based on actual textfield value
			@savedRange = null
			
			# activate focus event handlers:
			$(@textfield).focusin ()=>
				@savedRange = RangeUtil.getRange(@textfield)
				intervalId = setInterval(@detectChangeAndUpdate, 8000)

				# deactivate when focused out
				deactivate = ()=>
					@detectChangeAndUpdate() # check change for the last time
					clearInterval(intervalId)
					@textfield.off 'focusout', deactivate
					$(@textfield).get(0).normalize()

				$(@textfield).on 'focusout', deactivate

			# activate key event handlers
			$(@textfield).on 'keypress', (e)=>
				@detectChangeAndUpdate()


			# check for any update by the browser
			$(
				() =>
					setTimeout @detectChangeAndUpdate
			,
			200)

		attachHandler: ->
			@handler = new TextSheetHandler(this)



		detectChangeAndUpdate : () =>
			oldText = @savedText

			currentRange = RangeUtil.getRange(@textfield)

			if not currentRange
				return

			if !@savedRange or @savedRange[0] != currentRange[0] or @savedRange[1] != currentRange[1]
				@savedRange = currentRange

			if @savedText != $(@textfield).html()
				@savedText = $(@textfield).html()
				[operation, undoStr] = TextUtil.detectOperation(oldText, @savedText, @savedRange)
				operation.msgId = @history.write(operation)

				action = {action:"alterText", timestamp: @history.timestamp, params:{sheetId:@id, operations:@history.getPending()}}
				histObj = {action:"alterText", timestamp: @history.timestamp, params:{sheetId:@id, operations:@history.getPending()}}
				wallSocket.sendAction(action, histObj)


		alterText: (operation, isMine, timestamp) ->
			# Save current cursor and text
			#	 - if it differs from last one, create new operation?
			#	 - apply my change list => set text
			#	 - restore cursor

			# check for any possible updates in the form first
			@detectChangeAndUpdate()
			@history.timestamp = timestamp

			# save current cursor and range
			range = RangeUtil.getRange(@textfield)
			if not range
				range = [0,0,0]

			if isMine
				console.log("mine came (#{timestamp})")
				# respond only when it's valid 
				if @history.consolidateMine(operation)
					console.log("received mine: msgId #{operation.msgId}")
				else if @history.hasPending()
					console.warn("unexpected msgId came: #{operation.msgId} expected: #{@history.getPendingMsgId()}, timestamp:#{timestamp}, pending: ", @history.getPending())
				else
					console.warn("unexpected msgId came: #{operation.msgId}, timestamp:#{timestamp}")
			else
				
				# save the original base text
				original = @history.baseText

				[html, range] = @history.consolidateOther(operation, range)
				
				console.log("other came (#{timestamp}). base:", original, " altered:", html, " pending:", @history.pending)
				
				# update text field with the new html
				@textfield.html(html)
				@savedText = @textfield.html()
			 
				# restore original cursor and range (after applying 'other')
				RangeUtil.setRange(@textfield, range[0], range[1])

		undo: ->
			# TODO: properly set range
			range = RangeUtil.getRange(@textfield)
			if not range
				range = [0,0,0]

			[html, range] = @history.undo(range)
			@textfield.html(html)
			@savedText = @textfield.html()
			#RangeUtil.setRange
			action = {action:"alterText", timestamp: @history.timestamp, params:{sheetId:@id, operations:@history.getPending()}}
			wallSocket.sendAction(action)

			RangeUtil.setRange(@textfield, range[0], range[1])

		redo: ->
			# TODO: properly set range
			range = RangeUtil.getRange(@textfield)
			if not range
				range = [0,0,0]

			[html, range] = @history.redo(range)
			@textfield.html(html)
			@savedText = @textfield.html()
			#RangeUtil.setRange
			action = {action:"alterText", timestamp: @history.timestamp, params:{sheetId:@id, operations:@history.getPending()}}
			wallSocket.sendAction(action)

			RangeUtil.setRange(@textfield, range[0], range[1])


			


