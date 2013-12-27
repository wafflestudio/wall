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
	"editor",
	"hallo"], ($, TextUtil, Operation, StringWithState, RangeUtil, Sheet, TextSheetHandler, TemplateFactory, rangy, TextHistory, Editor, hallo) ->


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
			
			# add hallo TODO: remove this
			@element.find(".sheetTextField").mousedown((evt) =>
				if @innerElement.hasClass('activeSheet')
					evt.stopPropagation()
			).hallo({
				plugins:
					'halloformat' : {formattings: {"bold": true, "italic": true, "strikethrough": true, "underline": true}}
					'halloheadings' : {heading: [1,2,3,4,5,6]}
					'hallojustify' : {}
					'hallolists': {}
			})
			@innerElement = @element.children('.sheet')
			
		attachHandler: ->
			@handler = new TextSheetHandler(this)

		constructor: (params, timestamp) ->
			super(params)
			@contentType = "textSheet"
			@id = params.sheetId
			@textfield = @element.find('.sheetTextField')

			#textfield.on 'resize', (e) =>
				#if $(e.target).height() > @ih
					#@ih = $(e.target).height()
			
			@textfield.html(params.content)

			if @textfield.html() != params.content
				console.warn("browser altered content! :", @textfield.html(), ":", params.content)

			@textfield.Editor()

			@history = new TextHistory(params.content, timestamp)
			@savedText = params.content # saved text based on actual textfield value
			@savedRange = null
			
			# activate focus event handlers:
			$(@textfield).focusin (e)=>
				@savedRange = RangeUtil.getRange(@textfield)
				# undo/redo
				shortcut.onKeydown('ctrl + z, command + z', () => console.log("textsheet undo"); @undo())
				shortcut.onKeydown('ctrl + shift + z, command + shift + z', () => console.log("textsheet redo"); @redo())

				# deactivate when focused out
				deactivate = ()=>
					@textfield.off 'focusout', deactivate

				$(@textfield).on 'focusout', deactivate

			$(@textfield).focusout (e)=>
				shortcut.onKeydown('ctrl + z, command + z', () => console.log("textsheet undo"); stage.history.undo())
				shortcut.onKeydown('ctrl + shift + z, command + shift + z', () => console.log("textsheet redo"); stage.history.redo())

			$(@textfield).on('changeText', @detectChangeAndUpdate)



		detectChangeAndUpdate : () =>
			oldText = @savedText

			currentRange = RangeUtil.getRange(@textfield)

			if !@savedRange or @savedRange[0] != currentRange[0] or @savedRange[1] != currentRange[1]
				@savedRange = currentRange

			if @savedText != $(@textfield).html()
				@savedText = $(@textfield).html()
				[operation, undoStr] = TextUtil.detectOperation(oldText, @savedText, @savedRange)
				operation.msgId = @history.write(operation, undoStr)

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

			[html, newRange] = @history.undo(range)
			
			if not @history.hasPending()
				return

			@textfield.html(html)
			@savedText = @textfield.html()
			console.log("applied:", @savedText)
			action = {action:"alterText", timestamp: @history.timestamp, params:{sheetId:@id, operations:@history.getPending()}}
			wallSocket.sendAction(action)
			if newRange
				RangeUtil.setRange(@textfield, newRange[0], newRange[1])

		redo: ->
			# TODO: properly set range
			range = RangeUtil.getRange(@textfield)
			if not range
				range = [0,0,0]

			[html, newRange] = @history.redo(range)
			if not @history.hasPending()
				return

			@textfield.html(html)
			@savedText = @textfield.html()
			console.log("applied:", @savedText)
			action = {action:"alterText", timestamp: @history.timestamp, params:{sheetId:@id, operations:@history.getPending()}}
			wallSocket.sendAction(action)
			if newRange
				RangeUtil.setRange(@textfield, newRange[0], newRange[1])


			


