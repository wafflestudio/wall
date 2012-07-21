var glob = new function() {
	this.currentSheet = null;
	this.zoomLevel = 1;
}

var template = "<div class='sheetBox'> <div class='sheet' contenteditable = true><p class='text'>Box 1</p><div class='resizeHandle'></div></div><a class = 'boxClose'>x</a></div>";

function createSheet(id, params)  {
	return createNewSheet(id, params.x, params.y, params.width, params.height, params.text)
}

function moveSheet(params)  {
	var element = $("#sheet" + params.id)
	console.log(params.x, params.y);
	$(element).css('x', params.x);
	$(element).css('y', params.y);
}

function resizeSheet(params)  {
	var element = $("#sheet" + params.id)
	$(element).children('.sheet').css('width', params.width);
	$(element).children('.sheet').css('height', params.height);
}

function removeSheet(params)  {
	var element = $("#sheet" + params.id)
	$(element).remove();
}

function setText(params)  {
	// set Text
	var element = $("#sheet" + params.id)
	$(element).children('.sheet').html(params.text)
}

function createNewSheet(id, x, y, w, h, text) {
	var sheet = $(template).appendTo("#moveLayer")
	$(sheet).attr("id", "sheet" + id)
	$(sheet).css("x", x + "px")
	$(sheet).css("y", y + "px")
	$(sheet).children('.sheet').css("width", w + "px")
	$(sheet).children('.sheet').css("height", h + "px")
	$(sheet).find(".text").html(text)
	
	sheetHandler($(sheet));
	$(sheet).on("move", function(e, params) { wallSocket.send({action: "move", params: $.extend(params,{id:id})}) })
	$(sheet).on("resize", function(e, params) { wallSocket.send({action: "resize", params: $.extend(params, {id:id})}) })
	$(sheet).on("remove", function(e) { wallSocket.send({action:"remove", params:{id:id}}) })
	$(sheet).on("setText", function(e) { wallSocket.send({action:"setText", params:{id:id, text:$(sheet).children('.sheet').html()}}) })
	
	return sheet
}



function createRandomSheet()
{
	console.log("sheet create")
	
	var x = Math.random()*500
	var y = Math.random()*400
	var w = 200
	var h = 200
	var text = "text"
	wallSocket.send({action:"create", params:{x:x, y:y, width:w, height:h, text:text}})
	//createNewSheet(newId, x, y, w, h, text)
}


function sheetHandler(element)  {
	
	var deltax = 0;
	var deltay = 0;
	var startx = 0;
	var starty = 0;

	var startWidth = 0;
	var startHeight = 0;

	var hasMoved = false;

	function onMouseMove(e) {
		$(element).css('x', (startx + e.pageX - deltax)/glob.zoomLevel);
		$(element).css('y', (starty + e.pageY - deltay)/glob.zoomLevel);
		hasMoved = true;
	}

	function onMouseUp(e) {
		
		$(document).off('mousemove', onMouseMove);
		$(document).off('mouseup', onMouseUp);
		
		if(hasMoved)  {
			$(element).trigger('move', 
				{ id: $(element).attr('id').substr(5), x: (startx + e.pageX - deltax)/glob.zoomLevel,
			 	y: (starty + e.pageY - deltay)/glob.zoomLevel })
		}
		else
			$(element).children('.sheet').focus();

	}

	function onMouseDown(e) {
		
		hasMoved = false;
		//$("#moveLayer").append($(element));
		// 따로 remove할 필요 없이 걍 append하면 맨 뒤로 감..
		
		if (glob.currentSheet)
		{
			glob.currentSheet.find(".boxClose").hide();
			glob.currentSheet.children('.sheet').blur();
		}

		glob.currentSheet = $(element);
		glob.currentSheet.find(".boxClose").show();

		startx = parseInt($(element).css('x')) * glob.zoomLevel;
		starty = parseInt($(element).css('y')) * glob.zoomLevel;

		// 이걸 onZoomLevelChange로 묶어서 하나로 해야될듯
		// 휠 사용 도중 마우스를 클릭 안하라는법이 없음

		deltax = e.pageX;
		deltay = e.pageY;

		$(document).on('mousemove', onMouseMove);
		$(document).on('mouseup', onMouseUp);

		return false; // same as e.stopPropation + e.preventDefault
	}
	
	function onButtonMouseDown(e) {
		$(document).on('mousemove', onButtonMouseMove);
		$(document).on('mouseup', onButtonMouseUp);
	}

	function onButtonMouseMove(e) {
		console.log(e.pageX, e.pageY);
	}

	function onButtonMouseUp(e) {
		$(document).off('mousemove', onMouseMove);
		$(document).off('mouseup', onMouseUp);
		$(element).trigger("remove", {id:$(element).attr('id').substr(5)});
	}

	function onResizeMouseDown(e) {
		$(document).on('mousemove', onResizeMouseMove);
		$(document).on('mouseup', onResizeMouseUp);
		startWidth = parseInt($(element).children('.sheet').css('width')) * glob.zoomLevel;
		startHeight = parseInt($(element).children('.sheet').css('height')) * glob.zoomLevel;
		deltax = e.pageX;
		deltay = e.pageY;
		return false;
	}

	function onResizeMouseMove(e) {
		$(element).children('.sheet').css('width', (startWidth + e.pageX - deltax)/glob.zoomLevel);
		$(element).children('.sheet').css('height', (startHeight + e.pageY - deltay)/glob.zoomLevel);
	}

	function onResizeMouseUp(e) {

		$(document).off('mousemove', onResizeMouseMove);
		$(document).off('mouseup', onResizeMouseUp);
		$(element).trigger('resize', 
			{id:$(element).attr('id').substr(5), width: (startWidth + e.pageX - deltax)/glob.zoomLevel,
			 height: (startHeight + e.pageY - deltay)/glob.zoomLevel })
	}

	$(element).on('mousedown', '.boxClose', onButtonMouseDown);
	$(element).on('mousedown', '.resizeHandle', onResizeMouseDown);
	$(element).on('mousedown', onMouseDown);

	$(element).children('.sheet').on('change', function(e) { 
		$(element).trigger('setText', e)
	})
}

function wallHandler(element) {
	
	var deltax = 0;
	var deltay = 0;
	var startx = 0;
	var starty = 0;
	var movelayer = $("#moveLayer");
	var xImage = 0;
	var yImage = 0;
	var xLast = 0;
	var yLast = 0;
	
	function onMouseMove(e) {
		movelayer.css('x', (startx + e.pageX - deltax)/glob.zoomLevel);
		movelayer.css('y', (starty + e.pageY - deltay)/glob.zoomLevel);
		console.log(e.pageX + " " + e.pageY);
	}

	function onMouseUp() {
		$(document).off('mousemove', onMouseMove);
		$(document).off('mouseup', onMouseUp);
		if (glob.currentSheet)
			glob.currentSheet.find('.boxClose').hide();
	}

	function onMouseDown(e) {
		
		startx = parseInt(movelayer.css('x')) * glob.zoomLevel;
		starty = parseInt(movelayer.css('y')) * glob.zoomLevel;
		deltax = e.pageX;
		deltay = e.pageY;
		
		if (glob.currentSheet)
		{
			glob.currentSheet.find(".boxClose").hide();
			glob.currentSheet.children('.sheet').blur();
		}

		$(document).on('mousemove', onMouseMove);
		$(document).on('mouseup', onMouseUp);
		e.preventDefault();
		//return false; // same as e.stopPropation + e.preventDefault
	}

	function onMouseWheel(e, delta, deltaX, deltaY) {

		var xScreen = e.pageX - $(this).offset().left;
		var yScreen = e.pageY - $(this).offset().top - 40;
		// -40은 #wall이 위에 네비게이션 바 밑으로 들어간 40픽셀에 대한 compensation

		xImage = xImage + ((xScreen - xLast) / glob.zoomLevel);
		yImage = yImage + ((yScreen - yLast) / glob.zoomLevel);

		glob.zoomLevel += delta / 2.5;
		glob.zoomLevel = glob.zoomLevel < 0.3 ? 0.3 : (glob.zoomLevel > 10 ? 10 : glob.zoomLevel);

		var xNew = (xScreen - xImage) / glob.zoomLevel;
		var yNew = (yScreen - yImage) / glob.zoomLevel;

		xLast = xScreen;
		yLast = yScreen;

		$("#scaleLayer").css({scale : glob.zoomLevel});
		$("#scaleLayer").css('x', xNew);
		$("#scaleLayer").css('y', yNew);
		$("#scaleLayer").css({transformOrigin:xImage + 'px ' + yImage + 'px'});
		$(".boxClose").css({scale : 1 / glob.zoomLevel});

		return false;
	}

	$(element).on('mousedown', onMouseDown);
	$(element).on('mousewheel', onMouseWheel);
}


$(window).load(function(){

	wallHandler("#wall");
	$('#createBtn').click(createRandomSheet)

	$('[contenteditable]').live('focus', function() {
	    var $this = $(this);
	    $this.data('before', $this.html());
	    return $this;
	}).live('blur keyup paste', function() {
	    var $this = $(this);
	    if ($this.data('before') !== $this.html()) {
	        $this.data('before', $this.html());
	        $this.trigger('change');
	    }
	    return $this;
	});

});
