#glob = new ->
	#this.currentSheet = null
	#this.zoomLevel = 1
	#this.minimapToggled = 1
	#this.rightBarOffset = 267 + 80 + 30 # 80은 위에 userList, 30은 밑에 input
	
	#this.scaleLayerXPos = 0
	#this.scaleLayerYPos = 0

	#this.worldTop = 0
	#this.worldBottom = 0
	#this.worldLeft = 0
	#this.worldRight = 0

contentTypeEnum = {
  text: "text",
  image: "image"
}


textTemplate = "<div class='sheetBox' tabindex='-1'><div class='sheet'><div class='sheetTopBar'><h1 class='sheetTitle' contenteditable='true'> New Sheet </h1></div><div class='sheetText'><textarea class='sheetTextField'></textarea></div><div class='resizeHandle'></div></div><a class = 'boxClose'>x</a></div>"

imageTemplate = "<div class='sheetBox'><div class='imageSheet'><div class='sheetImage'></div><div class='resizeHandle'></div></div><a class = 'boxClose'>x</a></div>"


createSheet = (id, params) ->
  if params.contentType == contentTypeEnum.text
    createTextSheet id, params.x, params.y, params.width, params.height, params.title, params.content
  else if params.contentType == contentTypeEnum.image
    createImageSheet id, params.x, params.y, params.width, params.height, params.title, params.text, params.content


moveSheet = (params) ->
	element = $('#sheet' + params.id)
	element.css 'x', params.x
	element.css 'y', params.y

resizeSheet = (params) ->
	element = $('#sheet' + params.id)
	element.children('.sheet').css('width', params.width)
	element.children('.sheet').css('height', params.height)

removeSheet = (params) ->
	element = $('#sheet' + params.id)
	element.remove()
	element.off 'mousemove'
	element.off 'mouseup'
	element.off 'mousedown'
	$('#map_sheet' + params.id).remove()

setTitle = (params) ->
	$('#sheet' + params.id).find('.sheetTitle').html(params.title)

setText = (params) ->
	element = $($('#sheet' + params.id).find('textarea.sheetTextField'))
	text1 = element.getCode()
	text2 = params.text
	patch_text = diff_launch text1, text2
	patch = patch_launch text1, patch_text
	cursor = element.getCursorPosition()

	console.log "a: #{text1}"
	console.log "b: #{text2}"
	console.log "c: #{patch_text}"
	console.log "d: #{patch}"

	element.setCode(patch)
	element.setCursorPosition(cursor)


createSheetOnRandom = (contentType, content) ->
  title = "Untitled"
  console.log(contentType + " " + content)
  if contentType == contentTypeEnum.text
    x = Math.random() * ($(window).width() - 225) * 0.9 / glob.zoomLevel - (glob.scaleLayerXPos + (parseInt ($('#moveLayer').css 'x')) * glob.zoomLevel) / glob.zoomLevel
    y = Math.random() * ($(window).height() - 74) * 0.9 / glob.zoomLevel - (glob.scaleLayerYPos + (parseInt ($('#moveLayer').css 'y')) * glob.zoomLevel) / glob.zoomLevel
    w = 300
    h = 300

    wallSocket.send({action:"create", params:{x:x, y:y, width:w, height:h, title:title, contentType:contentType, text:content}})
  else if contentType == contentTypeEnum.image
    w = 0
    h = 0
    img = new Image()
    img.onload = ->
      w = this.width
      h = this.height
      ratio = w / h
      
      if w > 400
        w = 400
        h = 400 / ratio

      if h > 400
        h = 400
        w = 400 * ratio
    
      x = (-w + ($(window).width() - 225) / glob.zoomLevel) / 2 - (glob.scaleLayerXPos + (parseInt ($('#moveLayer').css 'x')) * glob.zoomLevel) / glob.zoomLevel
      y = (-h + ($(window).height() - 74) / glob.zoomLevel) / 2 - (glob.scaleLayerYPos + (parseInt ($('#moveLayer').css 'y')) * glob.zoomLevel) / glob.zoomLevel
      wallSocket.send({action:"create", params:{x:x, y:y, width:w, height:h, title:title, content:content, contentType:"image"}})

    img.src = content


createTextSheet = (id, x, y, w, h, title, text) ->
	sheet = $($(textTemplate).appendTo('#moveLayer'))
	prevTitle = title

	sheet.attr 'id', 'sheet' + id
	sheet.css 'x', x + 'px'
	sheet.css 'y', y + 'px'
	sheet.css 'outline', 'none'

	sheet.children('.sheet').css 'width', w + 'px'
	sheet.children('.sheet').css 'height', h + 'px'
	sheet.find('.sheetTitle').keydown (e) ->
		curTitle = sheet.find('.sheetTitle').html()
		if e.keyCode is 13
			curTitle = msg.substr(0, msg.length - 1) if curTitle.charAt(curTitle.length - 1) is '\n'

			if prevTitle isnt curTitle
				sheet.trigger 'setTitle'
				prevTitle = curTitle
				sheet.find('.sheetTitle').blur()
				return false
	.focusout (e) ->
		curTitle = sheet.find('.sheetTitle').html()
		$(sheet).trigger ('setTitle') if prevTitle isnt curTitle
		prevTitle = curTitle
	.html(title)

	sheet.find('textarea').html(text)

	sheetHandler(sheet)
	
	sheet.on 'move', (e, params) ->
		wallSocket.send {action : 'move', params : $.extend(params, {id : id})}

	sheet.on 'resize', (e, params) ->
		wallSocket.send {action : 'resize', params : $.extend(params, {id : id})}

	sheet.on 'remove', (e) ->
		wallSocket.send {action : 'remove', params : {id : id}}

	sheet.on 'setText', (e) ->
		wallSocket.send {action : 'setText', params : {id : id, text : sheet.find('textarea').val(), cursor : 1}}

	sheet.on 'setTitle', (e) ->
		wallSocket.send {action : 'setTitle', params : {id : id, title : sheet.find('.sheetTitle').html()}}

	$('#sheet' + id + ' textarea.sheetTextField').redactor {
		autoresize : true,
		air : true,
		airButtons : ['formatting', '|', 'bold', 'italic', 'deleted']
	}

	copyHandler(sheet)

	newMiniSheet = $($('<div class = "minimapElement"></div>').appendTo('#minimapWorld'))
	newMiniSheet.attr('id', 'map_sheet' + id)
	setMinimap()


createImageSheet = (id, x, y, w, h, title, text, url) ->
	#위에 타이틀과 밑에 텍스트도 있는 이미지 시트를 일단 생각하고..
	#하지만 구현에선 일단 타이틀과 텍스트는 차치함..
	
	sheet = $($(imageTemplate).appendTo('#moveLayer'))
	prevTitle = title

	sheet.attr 'id', 'sheet' + id
	sheet.css 'x', x + 'px'
	sheet.css 'y', y + 'px'
	sheet.children('.imageSheet').css 'width', w + 'px'
	sheet.children('.imageSheet').css 'height', h + 'px'
	sheet.children('.imageSheet').children('.sheetImage').css 'background', "url('#{url}') no-repeat"
	sheet.children('.imageSheet').children('.sheetImage').css 'background-size', '100%'
	imageSheetHandler(sheet)
	
	#copyHandler(sheet)

	newMiniSheet = $($('<div class = "minimapElement"></div>').appendTo('#minimapWorld'))
	newMiniSheet.attr('id', 'map_sheet' + id)
	setMinimap()


sheetHandler = (elem) ->
	deltax = 0
	deltay = 0
	startx = 0
	starty = 0
	startWidth = 0
	startHeight = 0
	hasMoved = false
	element = $(elem)

	onMouseMove = (e) ->
		#if focus then no move
		if $("*:focus").is(".sheetTitle") or $("*:focus").is(".redactor_editor")
			return

		element.css 'x', (startx + e.pageX - deltax) / glob.zoomLevel
		element.css 'y', (starty + e.pageY - deltay) / glob.zoomLevel
		hasMoved = true
		setMinimap()
	
	onMouseUp = (e) ->
		$(document).off 'mousemove', onMouseMove
		$(document).off 'mouseup', onMouseUp

		if hasMoved
			element.trigger 'move', {
				id : element.attr('id').substr(5),
				x : (startx + e.pageX - deltax) / glob.zoomLevel,
				y : (starty + e.pageY - deltay) / glob.zoomLevel
			}

	onMouseDown = (e) ->
		hasMoved = false
		$('#moveLayer').append element

		if glob.currentSheet
			glob.currentSheet.find('.boxClose').hide()
			glob.currentSheet.find('.sheetTextField').blur()
			$(glob.currentSheet.children('.sheet')).css 'border-top', ''
			$(glob.currentSheet.children('.sheet')).css 'margin-top', ''
			$('#map_' + glob.currentSheet.attr('id')).css 'background-color', 'black'

		glob.currentSheet = element
		glob.currentSheet.find('.boxClose').show()
		glob.currentSheet.children('.sheet').css 'border-top', '2px solid #FF4E58'
		glob.currentSheet.children('.sheet').css 'margin-top', '-2px'
		$('#map_' + glob.currentSheet.attr('id')).css 'background-color', 'crimson'

		startx = parseInt(element.css('x')) * glob.zoomLevel
		starty = parseInt(element.css('y')) * glob.zoomLevel

		deltax = e.pageX
		deltay = e.pageY

		$(document).on 'mousemove', onMouseMove
		$(document).on 'mouseup', onMouseUp
		e.stopPropagation()

	onButtonMouseDown = (e) ->
		$(document).on 'mouseup', onButtonMouseUp
	
	onButtonMouseMove = (e) ->
		console.log e.pageX, e.pageY
	
	onButtonMouseUp = (e) ->
		$(document).off 'mousemove', onMouseMove
		$(document).off 'mouseup', onMouseUp
		element.trigger 'remove', {id : element.attr('id').substr(5)}
	
	onResizeMouseDown = (e) ->
		$(document).on 'mousemove', onResizeMouseMove
		$(document).on 'mouseup', onResizeMouseUp
		startWidth = parseInt(element.children('.sheet').css('width')) * glob.zoomLevel
		startHeight = parseInt(element.children('.sheet').css('height')) * glob.zoomLevel
		deltax = e.pageX
		deltay = e.pageY
		return false

	onResizeMouseMove = (e) ->
		element.children('.sheet').css 'width', (startWidth + e.pageX - deltax) / glob.zoomLevel
		element.children('.sheet').css 'height', (startHeight + e.pageY - deltay) / glob.zoomLevel

	onResizeMouseUp = (e) ->
		$(document).off 'mousemove', onResizeMouseMove
		$(document).off 'mouseup', onResizeMouseUp
		element.trigger 'resize', {
			id : element.attr('id').substr(5),
			width : (startWidth + e.pageX - deltax) / glob.zoomLevel,
			height : (startHeight + e.pageY - deltay) / glob.zoomLevel
		}
	
	element.on 'mousedown', '.boxClose', onButtonMouseDown
	element.on 'mousedown', '.resizeHandle', onResizeMouseDown
	element.on 'mousedown', onMouseDown

	element.children('.sheet').on 'change', (e) ->
		element.trigger 'setText', e



imageSheetHandler = (elem) ->

	element = $(elem)
	deltax = 0
	deltay = 0
	startx = 0
	starty = 0
	startWidth = 0
	startHeight = 0
	imgWidth = parseInt(element.css('width'))
	imgHeight= parseInt(element.css('height'))
	hasMoved = false

	onMouseMove = (e) ->
		element.css 'x', (startx + e.pageX - deltax) / glob.zoomLevel
		element.css 'y', (starty + e.pageY - deltay) / glob.zoomLevel
		hasMoved = true
		setMinimap()
	
	onMouseUp = (e) ->
		$(document).off 'mousemove', onMouseMove
		$(document).off 'mouseup', onMouseUp

		if hasMoved
			element.trigger 'move', {
				id : element.attr('id').substr(5),
				x : (startx + e.pageX - deltax) / glob.zoomLevel,
				y : (starty + e.pageY - deltay) / glob.zoomLevel
			}

	onMouseDown = (e) ->
		hasMoved = false
		$('#moveLayer').append element

		if glob.currentSheet
			glob.currentSheet.find('.boxClose').hide()
			glob.currentSheet.find('.sheetTextField').blur()
			$(glob.currentSheet.children('.sheet')).css 'border-top', ''
			$(glob.currentSheet.children('.sheet')).css 'margin-top', ''
			$('#map_' + glob.currentSheet.attr('id')).css 'background-color', 'black'

		glob.currentSheet = element
		glob.currentSheet.find('.boxClose').show()
		glob.currentSheet.children('.sheet').css 'border-top', '2px solid #FF4E58'
		glob.currentSheet.children('.sheet').css 'margin-top', '-2px'
		$('#map_' + glob.currentSheet.attr('id')).css 'background-color', 'crimson'

		startx = parseInt(element.css('x')) * glob.zoomLevel
		starty = parseInt(element.css('y')) * glob.zoomLevel

		deltax = e.pageX
		deltay = e.pageY

		$(document).on 'mousemove', onMouseMove
		$(document).on 'mouseup', onMouseUp
		e.stopPropagation()
		return false

	onButtonMouseDown = (e) ->
		$(document).on 'mouseup', onButtonMouseUp
	
	onButtonMouseMove = (e) ->
		console.log e.pageX, e.pageY
	
	onButtonMouseUp = (e) ->
		$(document).off 'mousemove', onMouseMove
		$(document).off 'mouseup', onMouseUp
		element.trigger 'remove', {id : element.attr('id').substr(5)}
	
	onResizeMouseDown = (e) ->
		$(document).on 'mousemove', onResizeMouseMove
		$(document).on 'mouseup', onResizeMouseUp
		startWidth = parseInt(element.children('.imageSheet').css('width')) * glob.zoomLevel
		startHeight = parseInt(element.children('.imageSheet').css('height')) * glob.zoomLevel
		deltax = e.pageX
		deltay = e.pageY
		return false

	onResizeMouseMove = (e) ->
		dX = e.pageX - deltax
		dY = e.pageY - deltay
		ratio = imgWidth / imgHeight

		if Math.abs(dX / dY) > ratio
			element.children('.imageSheet').css 'width', (startWidth + dX) / glob.zoomLevel
			element.children('.imageSheet').css 'height', (startHeight + dX / ratio) / glob.zoomLevel
		else
			element.children('.imageSheet').css 'width', (startWidth + dY * ratio) / glob.zoomLevel
			element.children('.imageSheet').css 'height', (startHeight + dY) / glob.zoomLevel


	onResizeMouseUp = (e) ->
		$(document).off 'mousemove', onResizeMouseMove
		$(document).off 'mouseup', onResizeMouseUp
		element.trigger 'resize', {
			id : element.attr('id').substr(5),
			width : (startWidth + e.pageX - deltax) / glob.zoomLevel,
			height : (startHeight + e.pageY - deltay) / glob.zoomLevel
		}
	
	element.on 'mousedown', '.boxClose', onButtonMouseDown
	element.on 'mousedown', '.resizeHandle', onResizeMouseDown
	element.on 'mousedown', onMouseDown

	element.children('.imageSheet').on 'change', (e) ->
		element.trigger 'setText', e



wallHandler = (element) ->
	deltax = 0
	deltay = 0
	startx = 0
	starty = 0
	mL = $('#moveLayer')
	xScaleLayer = 0
	yScaleLayer = 0
	xWallLast = 0
	yWallLast = 0
	hasMoved = false

	onMouseMove = (e) ->
		mL.css 'x', (startx + e.pageX - deltax) / glob.zoomLevel
		mL.css 'y', (starty + e.pageY - deltay) / glob.zoomLevel
		setMinimap()
		hasMoved = true
	
	onMouseUp = ->
		$(document).off 'mousemove', onMouseMove
		$(document).off 'mouseup', onMouseUp
		if glob.currentSheet and not hasMoved
			glob.currentSheet.find('.boxClose').hide()
			glob.currentSheet.find('.sheetTextField').blur()
			glob.currentSheet.children('.sheet').css 'border-top', ''
			glob.currentSheet.children('.sheet').css 'margin-top', ''
			$('#map_' + glob.currentSheet.attr('id')).css 'background-color', 'black'
	
	onMouseDown = (e) ->
		hasMoved = false
		startx = parseInt((mL.css 'x')) * glob.zoomLevel
		starty = parseInt((mL.css 'y')) * glob.zoomLevel
		deltax = e.pageX
		deltay = e.pageY

		$(document).on 'mousemove', onMouseMove
		$(document).on 'mouseup', onMouseUp
		e.preventDefault()

	onMouseWheel = (e, delta, deltaX, deltaY) ->
		xWall = e.pageX - $(this).offset().left
		yWall = e.pageY - $(this).offset().top - 38

		#-38은 #wall이 위에 네비게이션 바 밑으로 들어간 38픽셀에 대한 compensation
		#xWall, yWall은 wall의 (0,0)을 origin으로 본 마우스 커서 위치

		xScaleLayer += (xWall - xWallLast) / glob.zoomLevel
		yScaleLayer += (yWall - yWallLast) / glob.zoomLevel
		
		#xWall - xWallLast는 저번과 현재의 마우스 좌표 차이 
		#xScaleLayer, yScaleLayer는 scaleLayer의 (0,0)을 origin 으로 본 마우스의 좌표이며, 이는 transformOrigin의 좌표가 됨
		
		glob.zoomLevel += delta / 2.5
		glob.zoomLevel = if glob.zoomLevel < 0.3 then 0.3 else (if glob.zoomLevel > 10 then 10 else glob.zoomLevel)

		xNew = (xWall - xScaleLayer) / glob.zoomLevel
		yNew = (yWall - yScaleLayer) / glob.zoomLevel
		
		#xNew, yNew는 wall기준 mouse위치와 scaleLayer기준 mouseLayer 의 차..
		
		xWallLast = xWall
		yWallLast = yWall

		glob.scaleLayerXPos = xWall - xScaleLayer * glob.zoomLevel
		glob.scaleLayerYPos = yWall - yScaleLayer * glob.zoomLevel

		#scaleLayer의 좌표를 wall의 기준으로 저장

		sL = $('#scaleLayer')
		sL.css {scale : glob.zoomLevel}
		sL.css 'x', xNew
		sL.css 'y', yNew
		sL.css({transformOrigin:xScaleLayer + 'px ' + yScaleLayer + 'px'})
		$('.boxClose').css {scale : 1 / glob.zoomLevel}
		$('#zoomLevelText').text ("#{parseInt(glob.zoomLevel * 100)}%")
		setMinimap()
		return false

	$(element).on 'mousedown', onMouseDown
	$(element).on 'mousewheel', onMouseWheel
	


toggleMinimap = ->
	if glob.minimapToggled
		glob.minimapToggled = 0
		$('#miniMap').animate {right: '-220'}, 200, toggleMinimapFinished
	else
		glob.minimapToggled = 1
		$('#chatWindow').animate {height: '-=190'}, 200, toggleMinimapFinished

toggleMinimapFinished = ->
	if glob.minimapToggled
		$('#miniMap').animate {right: '0'}, 200
		glob.rightBarOffset += 190
	else
		$('#chatWindow').animate {height: '+=190'}, 200
		glob.rightBarOffset -= 190

setMinimap = ->
	
	#좌표는 moveLayer의 기준에서 본 wall의 좌표!
	sB = $('.sheetBox')
	screenWidth = ($(window).width() - 225) / glob.zoomLevel
	screenHeight = ($(window).height() - 74) / glob.zoomLevel
	screenTop = -(glob.scaleLayerYPos + (parseInt ($('#moveLayer').css 'y')) * glob.zoomLevel) / glob.zoomLevel
	screenBottom = screenTop + screenHeight
	screenLeft = -(glob.scaleLayerXPos + (parseInt ($('#moveLayer').css 'x')) * glob.zoomLevel) / glob.zoomLevel
	screenRight = screenLeft + screenWidth

	glob.worldTop = screenTop
	glob.worldBottom = screenBottom
	glob.worldLeft = screenLeft
	glob.worldRight = screenRight

	updateWorldSize = (elem) ->
		elemX = parseInt (elem.css('x'))
		elemY = parseInt (elem.css('y'))
		elemWidth = parseInt (elem.css('width'))
		elemHeight = parseInt (elem.css('height'))

		glob.worldLeft = elemX if elemX < glob.worldLeft
		glob.worldRight = elemX + elemWidth if elemX + elemWidth > glob.worldRight
		glob.worldTop = elemY if elemY < glob.worldTop
		glob.worldBottom = elemY + elemHeight if elemY + elemHeight > glob.worldBottom
	
	updateWorldSize $(elem) for elem in sB

	worldWidth = glob.worldRight - glob.worldLeft
	worldHeight = glob.worldBottom - glob.worldTop
	ratio = 1
	mW = $('#minimapWorld')
	mWC = $('#minimapCurrentScreen')

	if (worldWidth / worldHeight) > (224 / 185)
		ratio = 224 / worldWidth
		mW.css 'width', 224
		mW.css 'height', worldHeight * ratio
		mW.css 'top', (185 - worldHeight * ratio) / 2
		mW.css 'left', 0
	
	else
		ratio = 185 / worldHeight
		mW.css 'width', worldWidth * ratio
		mW.css 'height', 185
		mW.css 'top', 0
		mW.css 'left', (224 - worldWidth * ratio) / 2
	
	mWC.css 'width', screenWidth * ratio
	mWC.css 'height', screenHeight * ratio
	mWC.css 'top', (screenTop - glob.worldTop) * ratio
	mWC.css 'left', (screenLeft - glob.worldLeft) * ratio
	
	shrinkMiniSheet = (elem) ->
		miniSheet = $('#map_' + elem.attr('id'))
		miniSheet.css 'left', ((parseInt elem.css('x')) - glob.worldLeft) * ratio
		miniSheet.css 'top', ((parseInt elem.css('y')) - glob.worldTop) * ratio
		miniSheet.css 'width', ((parseInt elem.css('width'))) * ratio
		miniSheet.css 'height', ((parseInt elem.css('height'))) * ratio
	
	shrinkMiniSheet $(elem) for elem in sB

window.createSheet = createSheet
window.moveSheet = moveSheet
window.removeSheet = removeSheet
window.resizeSheet = resizeSheet
window.setTitle = setTitle
window.setMinimap = setMinimap
window.setText = setText
window.sheetHandler = sheetHandler

window.createSheetOnRandom = createSheetOnRandom
window.createTextSheet = createTextSheet
window.createImageSheet = createImageSheet

$(window).resize ->
	$('#chatWindow').height ($(window).height() - glob.rightBarOffset)
	setMinimap()

$(window).load ->
	wallHandler('#wall')
	
	$('#fileupload').fileupload	{
		dataType : 'json',
		done : (e, data) ->
			$.each(data.result, (index, file) ->
        createSheetOnRandom(contentTypeEnum.image, "/assets/files/#{file.name}")
      )
	}

	$('.createBtn').live('click', () ->
	  if $(this).attr('rel') == 'text'
      createSheetOnRandom(contentTypeEnum.text, "text")
	)

	$('#minimapBtn').click toggleMinimap
	$('#chatWindow').height ($(window).height() - glob.rightBarOffset)
	$('#zoomLevelText').text ("#{parseInt(glob.zoomLevel * 100)}%")
	$('#currentWallNameText').text "First wall"

	$('.sheetText [contenteditable]').live 'focus', ->
		$this = $(this)
		$this.data 'before', $this.html()
		$this
	.live 'blur keyup paste', ->
		$this = $(this)
		if $this.data('before') isnt $this.html()
			$this.data('before', $this.html())
			$this.trigger('change')
		$this

