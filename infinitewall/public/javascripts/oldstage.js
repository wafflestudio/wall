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

	this.tempImageID = 20000;
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


function toOriginal() {
	$('#moveLayer').css('x', 0);
	$('#moveLayer').css('y', 0);
	$('#scaleLayer').css('x', 0);
	$('#scaleLayer').css('y', 0);
	$('#scaleLayer').css({transformOrigin : '0px 0px'});
	glob.scaleLayerXPos = 0;
	glob.scaleLayerYPos = 0;
	setMinimap();
}
