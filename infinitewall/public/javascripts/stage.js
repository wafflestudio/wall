var glob = new function() {
	this.currentSheet = null;
	this.zoomLevel = 1;
	this.minimapToggled = 1;
	this.rightBarOffset = 267 + 80 + 30; // 80은 위에 userList, 30은 밑에 input 
	
	this.scaleLayerXPos = 0;
	this.scaleLayerYPos = 0;

	this.worldTop = 0;
	this.worldBottom = 0;
	this.worldLeft = 0;
	this.worldRight = 0;
}

var template = "<div class='sheetBox'><div class='sheet'><div class='sheetTopBar'><h1 class='sheetTitle' contenteditable='true'> New Sheet </h1></div><div class='sheetText'><textarea class='sheetTextField'></textarea></div><div class='resizeHandle'></div></div><a class = 'boxClose'>x</a></div>";

function createSheet(id, params)  {
	return createNewSheet(id, params.x, params.y, params.width, params.height, params.title, params.text)
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
	$(element).off('mousemove');
	$(element).off('mouseup');
	$(element).off('mousedown');

	var minimapElement = $("#map_sheet" + params.id);
	$(minimapElement).remove();

}

function setTitle(params)  {
	var element = $("#sheet" + params.id)
	// TODO: set title
	$(element).find('sheetTitle').html(params.title)
}

/*
 * google diff patch
 */
var dmp = new diff_match_patch();

var patch_text = '';

function diff_launch(text1, text2) {
   var diff = dmp.diff_main(text1, text2, true);

   if (diff.length > 2) {
      dmp.diff_cleanupSemantic(diff);
   }

   var patch_list = dmp.patch_make(text1, text2, diff);
   patch_text = dmp.patch_toText(patch_list);
   return patch_text;
}


function patch_launch(text1, patch_text) {
   var patches = dmp.patch_fromText(patch_text);
   var results = dmp.patch_apply(patches, text1);

   patch = results[0];
   results = results[1];
   
   for (var x = 0; x < results.length; x++) {
      if (results[x]) { // OK
      } else {
      }
   }
   return patch;
}

(function ($, undefined) {
   $.fn.getCursorPosition = function() {
      var el = $(this).get(0);
      var pos = 0;
      if('selectionStart' in el) {
         pos = el.selectionStart;
      } else if('selection' in document) {
         el.focus();
         var Sel = document.selection.createRange();
         var SelLength = document.selection.createRange().text.length;
         Sel.moveStart('character', -el.value.length);
         pos = Sel.text.length - SelLength;
      }
      return pos;
   }
})(jQuery);

(function ($) {
   $.fn.setCursorPosition = function(pos) {
      if ($(this).get(0).setSelectionRange) {
         $(this).get(0).setSelectionRange(pos, pos);
      } else if ($(this).get(0).createTextRange) {
         var range = $(this).get(0).createTextRange();
         range.collapse(true);
         range.moveEnd('character', pos);
         range.moveStart('character', pos);
         range.select();
      }
   }
})(jQuery);

function setText(params)  {
	// set Text
	var element = $("#sheet" + params.id).find('textarea.sheetTextField');
	var text1 = $(element).getCode();
	console.log("a: " + text1);
	var text2 = params.text;
	console.log("b: " + text2);
	var patch_text = diff_launch(text1, text2);
	console.log("c: " + patch_text);
	var patch = patch_launch(text1, patch_text);
	console.log("d: " + patch);
	var cursor = $(element).getCursorPosition();
//	var temp = $("#sheet + params.id").find('.redactor_editor');
//	var temp_cursor = $(temp).getCursorPosition();
//	console.log(temp_cursor);
	$(element).setCode(patch);
	$(element).setCursorPosition(cursor);
}

function createNewSheet(id, x, y, w, h, title, text) {
	var sheet = $(template).appendTo("#moveLayer")
	var prevTitle = title;
	//var range = rangy.createRange();
	$(sheet).attr("id", "sheet" + id)
	$(sheet).css("x", x + "px")
	$(sheet).css("y", y + "px")
	$(sheet).children('.sheet').css("width", w + "px")
	$(sheet).children('.sheet').css("height", h + "px")
	//$(sheet).find(".text").html(text)
	$(sheet).find(".sheetTitle").keydown(function(e){
		var curTitle = $(sheet).find(".sheetTitle").html()
		if(e.keyCode == 13)  {
			if(curTitle.charAt(curTitle.length-1) == '\n')
				curtitle = msg.substr(0,msg.length-1)

			if(prevTitle != curTitle)  {
				$(sheet).trigger('setTitle');
				prevTitle = curTitle;
				$(sheet).find(".sheetTitle").blur()
				return false;
			}
		}
	}).focusout(function(e) {
		var curTitle = $(sheet).find(".sheetTitle").html()
		if(prevTitle != curTitle)
			$(sheet).trigger('setTitle');
		prevTitle = curTitle;
	}).html(title)

	$(sheet).find("textarea").html(text)

  //sheet handler
	sheetHandler($(sheet));
	$(sheet).on("move", function(e, params) { wallSocket.send({action: "move", params: $.extend(params,{id:id})}) })
	$(sheet).on("resize", function(e, params) { wallSocket.send({action: "resize", params: $.extend(params, {id:id})}) })
	$(sheet).on("remove", function(e) { wallSocket.send({action:"remove", params:{id:id}}) })
	//$(sheet).on("setText", function(e) { wallSocket.send({action:"setText", params:{id:id, text:$(sheet).children('.sheet').html(), cursor: 1}}) })
	$(sheet).on("setText", function(e) { wallSocket.send({action:"setText", params:{id:id, text:$(sheet).find('textarea').val(), cursor: 1}}) })
	$(sheet).on("setTitle", function(e) { wallSocket.send({action:"setTitle", params:{id:id, title:$(sheet).find('.sheetTitle').html()}}) })
    $('#sheet'+id+' textarea.sheetTextField').redactor({
       autoresize: true,
       air: true,
       airButtons: ['formatting', '|', 'bold', 'italic', 'deleted']
    });	

  //copy handler
	copyHandler($(sheet));

	var newMiniSheet = $($("<div class = 'minimapElement'></div>").appendTo("#minimapWorld"));
	newMiniSheet.attr("id", "map_sheet" + id);
	setMinimap();
	
	return sheet
}



function createRandomSheet()
{
	console.log("sheet create")

	var x = Math.random()*500
	var y = Math.random()*400
	var w = 300
	var h = 300
	var title = "untitled"
	var text = "text"
	wallSocket.send({action:"create", params:{x:x, y:y, width:w, height:h, title:title, text:text}})
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
		setMinimap();
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
			$(element).find('.sheetTextField').focus();

	}

	function onMouseDown(e) {

		hasMoved = false;
		$("#moveLayer").append($(element));
		// 따로 remove할 필요 없이 걍 append하면 맨 뒤로 감..

		if (glob.currentSheet)
		{
			glob.currentSheet.find(".boxClose").hide();
			glob.currentSheet.find('.sheetTextField').blur();
			glob.currentSheet.children('.sheet').css("border-top", "");
			glob.currentSheet.children('.sheet').css("margin-top", "");
			$("#map_" + glob.currentSheet.attr("id")).css("background-color", "black");
		}

		glob.currentSheet = $(element);
		glob.currentSheet.find(".boxClose").show();
		glob.currentSheet.children(".sheet").css("border-top", "2px solid #FF4E58");
		glob.currentSheet.children(".sheet").css("margin-top", "-2px");
		$("#map_" + glob.currentSheet.attr("id")).css("background-color", "crimson");

		startx = parseInt($(element).css('x')) * glob.zoomLevel;
		starty = parseInt($(element).css('y')) * glob.zoomLevel;

		// 이걸 onZoomLevelChange로 묶어서 하나로 해야될듯
		// 휠 사용 도중 마우스를 클릭 안하라는법이 없음

		deltax = e.pageX;
		deltay = e.pageY;

		$(document).on('mousemove', onMouseMove);
		$(document).on('mouseup', onMouseUp);
		e.stopPropagation();
		//return false; // same as e.stopPropation + e.preventDefault
	}

	function onButtonMouseDown(e) {
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
		//$(element).find('textarea').on('keyup', function(e) { 
			$(element).trigger('setText', e);
	})
	$(element).find('textarea').on('focusin', function(e) { 
	})
	$(element).find('textarea').on('focusout', function(e) { 
	})
}

function wallHandler(element) {

	var deltax = 0;
	var deltay = 0;
	var startx = 0;
	var starty = 0;
	var movelayer = $("#moveLayer");
	var xScaleLayer = 0;
	var yScaleLayer = 0;
	var xWallLast = 0;
	var yWallLast = 0;
	var hasMoved = false;

	function onMouseMove(e) {
		movelayer.css('x', (startx + e.pageX - deltax)/glob.zoomLevel);
		movelayer.css('y', (starty + e.pageY - deltay)/glob.zoomLevel);
		console.log(e.pageX + " " + e.pageY);
		setMinimap();
		hasMoved = true;
	}

	function onMouseUp() {
		$(document).off('mousemove', onMouseMove);
		$(document).off('mouseup', onMouseUp);
		
		if (glob.currentSheet && !hasMoved)
		{
			glob.currentSheet.find('.boxClose').hide();
			glob.currentSheet.find('.sheetTextField').blur();
			glob.currentSheet.children(".sheet").css("border-top", "");
			glob.currentSheet.children(".sheet").css("margin-top", "");
			$("#map_" + glob.currentSheet.attr("id")).css("background-color", "black");
		}
	}

	function onMouseDown(e) {

		hasMoved = false;
		startx = parseInt(movelayer.css('x')) * glob.zoomLevel;
		starty = parseInt(movelayer.css('y')) * glob.zoomLevel;
		deltax = e.pageX;
		deltay = e.pageY;

		$(document).on('mousemove', onMouseMove);
		$(document).on('mouseup', onMouseUp);
		e.preventDefault();
		//return false; // same as e.stopPropation + e.preventDefault
	}

	function onMouseWheel(e, delta, deltaX, deltaY) {

		var xWall = e.pageX - $(this).offset().left;
		var yWall = e.pageY - $(this).offset().top - 38;
		// -38은 #wall이 위에 네비게이션 바 밑으로 들어간 38픽셀에 대한 compensation
		// xWall, yWall 은 wall의 (0,0)을 origin 으로 본 마우스 커서 위치

		xScaleLayer = xScaleLayer + ((xWall - xWallLast) / glob.zoomLevel);
		yScaleLayer = yScaleLayer + ((yWall - yWallLast) / glob.zoomLevel);

		// xWall - xWallLast는 저번과 현재의 마우스 좌표 차이 
		// xScaleLayer, yScaleLayer는 scaleLayer의 (0,0)을 origin 으로 본 마우스의 좌표이며, 이는 transformOrigin의 좌표가 됨

		glob.zoomLevel += delta / 2.5;
		glob.zoomLevel = glob.zoomLevel < 0.3 ? 0.3 : (glob.zoomLevel > 10 ? 10 : glob.zoomLevel);
		glob.zoomLevel = parseInt(glob.zoomLevel * 100) / 100;

		// 새로운 scale값을 지정해 주고 

		var xNew = (xWall - xScaleLayer) / glob.zoomLevel;
		var yNew = (yWall - yScaleLayer) / glob.zoomLevel;

		// xNew, yNew는 wall기준 mouse위치와 scaleLayer기준 mouseLayer 의 차..

		xWallLast = xWall;
		yWallLast = yWall;

		glob.scaleLayerXPos = xWall - xScaleLayer * glob.zoomLevel;
		glob.scaleLayerYPos = yWall - yScaleLayer * glob.zoomLevel;

		// scaleLayer의 좌표를 wall의 기준으로 저장함

		$("#scaleLayer").css({scale : glob.zoomLevel});
		$("#scaleLayer").css('x', xNew);
		$("#scaleLayer").css('y', yNew);
		$("#scaleLayer").css({transformOrigin:xScaleLayer + 'px ' + yScaleLayer + 'px'});
		$(".boxClose").css({scale : 1 / glob.zoomLevel});
		$("#zoomLevelText").text(parseInt(glob.zoomLevel * 100) + "%");
		setMinimap();

		return false;
	}

	$(element).on('mousedown', onMouseDown);
	$(element).on('mousewheel', onMouseWheel);
}

function toggleMinimap() {

	if (glob.minimapToggled == 1)
	{
		glob.minimapToggled = 0;
		$("#miniMap").animate({right: '-220'}, 200, toggleMinimapFinished);
	}
	else
	{
		glob.minimapToggled = 1;
		$("#chatWindow").animate({height: '-=190'}, 200, toggleMinimapFinished);
	}

}

function toggleMinimapFinished() {

	if (glob.minimapToggled == 1)
	{
		$("#miniMap").animate({right: '0'}, 200);
		glob.rightBarOffset += 190;
		console.log(glob.rightBarOffset);
	}
	else 
	{
		$("#chatWindow").animate({height: '+=190'}, 200);
		glob.rightBarOffset -= 190;
		console.log(glob.rightBarOffset);
	}

}

function setMinimap() {

	var sB = $(".sheetBox");

	// 좌표는 moveLayer의 기준에서 본 wall의 좌표!

	var screenWidth = ($(window).width() - 225) / glob.zoomLevel; // screen 의 상대적 크기
	var screenHeight = ($(window).height() - 74) / glob.zoomLevel;

	var screenTop = -(glob.scaleLayerYPos + parseInt($("#moveLayer").css("y")) * glob.zoomLevel) / glob.zoomLevel;
	var screenBottom = screenTop + screenHeight;
	var screenLeft = -(glob.scaleLayerXPos + parseInt($("#moveLayer").css("x")) * glob.zoomLevel) / glob.zoomLevel;
	var screenRight = screenLeft + screenWidth;


	// scaleLayer 의 좌표에서 moveLayer 의 좌표를 더한 것의 마이너스 취한것

	glob.worldTop = screenTop;
	glob.worldBottom = screenBottom;
	glob.worldLeft = screenLeft;
	glob.worldRight = screenRight;

	// 일단 이렇게 넣어 두고..

	for (i = 0; i < sB.length; i++)
	{
		var elem = $(sB[i]);
		var elemX = parseInt(elem.css("x"));
		var elemY = parseInt(elem.css("y"));
		var elemWidth = parseInt(elem.css("width"));
		var elemHeight = parseInt(elem.css("height"));

		// moveLayer의 기준에서 봤을때 elem.css("x")가 이 element의 좌표이다..!

		if (elemX < glob.worldLeft)
			glob.worldLeft = elemX;

		if (elemX + elemWidth > glob.worldRight)
			glob.worldRight = elemX + elemWidth;

		if (elemY < glob.worldTop)
			glob.worldTop = elemY;

		if (elemY + elemHeight > glob.worldBottom)
			glob.worldBottom = elemY + elemHeight;
	}

	// worldSize를 구하기 위한 노력들.. 왼쪽 오른쪽 위 아래의 boundaries를 구해야한다

	var worldWidth = glob.worldRight - glob.worldLeft;
	var worldHeight = glob.worldBottom - glob.worldTop;
	var ratio = 1;

	if ((worldWidth / worldHeight) > (224 / 185)) // 만약 가로 비율이 더 길다면
	{
		ratio = 224 / worldWidth; 
		$("#minimapWorld").css("width", 224);
		$("#minimapWorld").css("height", worldHeight * ratio);
		$("#minimapWorld").css("top", (185 - worldHeight * ratio) / 2);
		$("#minimapWorld").css("left", 0);
	}

	else
	{
		ratio = 185 / worldHeight;
		$("#minimapWorld").css("width", worldWidth * ratio);
		$("#minimapWorld").css("height", 185);
		$("#minimapWorld").css("top", 0);
		$("#minimapWorld").css("left", (224 - worldWidth * ratio) / 2);

	}

	$("#minimapCurrentScreen").css("width", screenWidth * ratio);
	$("#minimapCurrentScreen").css("height", screenHeight * ratio);
	$("#minimapCurrentScreen").css("top", (screenTop - glob.worldTop) * ratio);
	$("#minimapCurrentScreen").css("left", (screenLeft - glob.worldLeft) * ratio);

	// 각각의 mini element들을 줄일 ratio를 찾음

	for (i = 0; i < sB.length; i++)
	{
		var elem = $(sB[i]);
		var newWidth = parseInt(parseInt(elem.css("width")) * ratio);
		var newHeight = parseInt(parseInt(elem.css("height")) * ratio);

		var newMiniSheet = $("#map_" + sB[i].id);

		newMiniSheet.css("left", (parseInt(elem.css("x")) - glob.worldLeft) * ratio);
		newMiniSheet.css("top", (parseInt(elem.css("y")) - glob.worldTop) * ratio);
		newMiniSheet.css('width', newWidth);
		newMiniSheet.css("height", newHeight);
	}

}

$(window).resize(function(){
	$("#chatWindow").height($(window).height() - glob.rightBarOffset);
	setMinimap();
});

$(window).load(function(){

	wallHandler("#wall");

	$('#createBtn').click(createRandomSheet);
	$('#minimapBtn').click(toggleMinimap);
	$("#chatWindow").height($(window).height() - glob.rightBarOffset);
	$("#zoomLevelText").text(parseInt(glob.zoomLevel * 100) + "%");

	$('.sheetText [contenteditable]').live('focus', function() {
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
