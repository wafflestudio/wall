var glob = new function() {
	this.currentSheet = null;
	this.zoomLevel = 1;
	this.xImage = 0;
	this.yImage = 0;
	this.xLast = 0;
	this.yLast = 0;
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

	function onMouseUp() {
		$(document).off('mousemove', onMouseMove);
		$(document).off('mouseup', onMouseUp);
		
		if (hasMoved == false)
			$(element).children('.sheet').focus();

		//$(element).trigger('stop')
	}

	function onMouseDown(e) {
		
		hasMoved = false;
		$("#moveLayer").append($(element));
		// 따로 remove할 필요 없이 걍 append하면 맨 뒤로 감..
		
		if (glob.currentSheet)
		{
			glob.currentSheet.find(".boxClose").hide();
			glob.currentSheet.children('.sheet').blur();
		}

		glob.currentSheet = $(element);
		glob.currentSheet.find(".boxClose").show();

		startx = parseInt($(element).css('x'));
		starty = parseInt($(element).css('y'));
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
		$(element).remove();
	}

	function onResizeMouseDown(e) {
		$(document).on('mousemove', onResizeMouseMove);
		$(document).on('mouseup', onResizeMouseUp);
		startWidth = parseInt($(element).children('.sheet').css('width'));
		startHeight = parseInt($(element).children('.sheet').css('height'));
		deltax = e.pageX;
		deltay = e.pageY;
		return false;
	}

	function onResizeMouseMove(e) {
		$(element).children('.sheet').css('width', (startWidth + e.pageX - deltax)/glob.zoomLevel);
		$(element).children('.sheet').css('height', (startHeight + e.pageY - deltay)/glob.zoomLevel);
		console.log($(element).find('.sheet').css('width'), startWidth);
	}


	function onResizeMouseUp(e) {
		$(document).off('mousemove', onResizeMouseMove);
		$(document).off('mouseup', onResizeMouseUp);
	}

	$(element).on('mousedown', '.boxClose', onButtonMouseDown);
	$(element).on('mousedown', '.resizeHandle', onResizeMouseDown);
	$(element).on('mousedown', onMouseDown);
}

function wallHandler(element) {
	
	var deltax = 0;
	var deltay = 0;
	var startx = 0;
	var starty = 0;
	var movelayer = $("#moveLayer");
	var xImage = 0;
	var yImage = 0;
	var scale = 1;
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
		
		startx = parseInt(movelayer.css('x'));
		starty = parseInt(movelayer.css('y'));
		deltax = e.pageX;
		deltay = e.pageY;
		
		if (glob.currentSheet)
		{
			glob.currentSheet.find(".boxClose").hide();
			glob.currentSheet.children('.sheet').blur();
		}

		$(document).on('mousemove', onMouseMove);
		$(document).on('mouseup', onMouseUp);

		return false; // same as e.stopPropation + e.preventDefault
	}

	function onMouseWheel(e, delta, deltaX, deltaY) {

		var xScreen = e.pageX - $(this).offset().left;
		var yScreen = e.pageY - $(this).offset().top;

		xImage = xImage + ((xScreen - xLast) / glob.zoomLevel);
		yImage = yImage + ((yScreen - yLast) / glob.zoomLevel);

		glob.zoomLevel += delta;
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

	sheetHandler("#one");
	sheetHandler("#two");
	wallHandler("#wall");
});
