/*
 * dependency
 *
 * <script type="text/javascript" src="http://rangy.googlecode.com/svn/trunk/lib/log4javascript.js"></script>
 * <script type="text/javascript" src="http://rangy.googlecode.com/svn/trunk/dev/rangy-core.js"></script>
 * <script type="text/javascript" src="http://rangy.googlecode.com/svn/trunk/dev/rangy-textrange.js"></script>
 * <script type="text/javascript" src="http://rangy.googlecode.com/svn/trunk/dev/rangy-cssclassapplier.js"></script>
 * <script type="text/javascript" src="http://code.jquery.com/jquery-1.8.2.min.js"></script>
 */

/* 앞에다가 추가한 경우 */


var initContent = "";

$(document).ready(function() {
   rangy.init();
});

(function($) {
 return $.fn.wallEditor = function() {
    var sheet = this[0];
    var savedSel = null;
    sheet.keyCode = 0
    sheet.beforeAndAfter = {before: {start: 0, end: 0, cLength: 0}, after: {start: 0, end: 0, cLength: 0}};

    function initEditor(content, length, cursor) {
       sheet.beforeAndAfter = {before: {start: 0, end: 0, cLength: length}, after: {start: 0, end: 0, cLength: length}};
       if(cursor) {
          savedSel = null;
       }
       if(content) {
          $(sheet).html(initContent);
       }
    };

    $(this).focus(function() {
       console.log('focus');
       console.log($(sheet).html());
       initEditor(false, rangy.innerText(this).length, false);
    });
    $(this).focusout(function() {
       console.log('focusout');
       initEditor(false, rangy.innerText(this).length, true);
    });
    $(this).bind('activate', function() {
       console.log('click');
       savedSel = rangy.getSelection().saveCharacterRanges(this);

       var start = savedSel[0].range.start;
       var end = savedSel[0].range.end;
       var cLength = 0;

       cLength = rangy.innerText(this).length;
       sheet.beforeAndAfter = {before: {start: start, end: end, cLength: cLength}, after: {start: start, end: end, cLength: cLength}};
    });

    $(this).keyup(function(e) {
      savedSel = rangy.getSelection().saveCharacterRanges(this);
      var start = savedSel[0].range.start;
      var end = savedSel[0].range.end;
      var cLength = 0;
      sheet.keyCode = e.keyCode;

      var content = $(this).html();
      if(content == "" || content == "<br>") {
         $(sheet).html(initContent);
         sheet.beforeAndAfter.after = {start: start, end: end, cLength: cLength};
      }
      /*
      else if(content.match(/\<div\>\<br( |\/)*\>\<\/div\>/) != null) {
         console.log('init------');
         content = content.replace(/\<div\>\<br( |\/)*\>\<\/div\>/g, initContent);
         //$(sheet).html(content);
         sheet.beforeAndAfter.after = {start: start, end: end, cLength: cLength};
      }
      */
      else {
         cLength = rangy.innerText(this).length;
         sheet.beforeAndAfter.after = {start: start, end: end, cLength: cLength};
      }
      $(this).parents('div.sheetBox').trigger('setText', e);
      var diff = cLength - sheet.beforeAndAfter.before.cLength;
      sheet.beforeAndAfter.after = {start: start - diff, end: end - diff, cLength: cLength};
    });

    $(this).bind('setCursor', function(e, activatedBeforeAndAfter) {
      console.log('setCursor');
      if(activatedBeforeAndAfter.before.start <= sheet.beforeAndAfter.before.start) {
         if(activatedBeforeAndAfter.before.end <= sheet.beforeAndAfter.before.start) {
            console.error('type1');
            var diff = activatedBeforeAndAfter.after.cLength - activatedBeforeAndAfter.before.cLength;
            sheet.beforeAndAfter.after.start += diff;
            sheet.beforeAndAfter.after.end += diff;
            sheet.beforeAndAfter.after.start = sheet.beforeAndAfter.after.start < 0 ? 0 : sheet.beforeAndAfter.after.start;
            sheet.beforeAndAfter.after.end = sheet.beforeAndAfter.after.end < 0 ? 0 : sheet.beforeAndAfter.after.end;
         }
         else {
            console.error('type2');
            sheet.beforeAndAfter.after.start = activatedBeforeAndAfter.after.start;
            sheet.beforeAndAfter.after.end = sheet.beforeAndAfter.after.start;
         }
      }
      else if(activatedBeforeAndAfter.before.start != sheet.beforeAndAfter.before.start && activatedBeforeAndAfter.before.end >= sheet.beforeAndAfter.before.end) {
         if(activatedBeforeAndAfter.after.end < sheet.beforeAndAfter.after.end) {
            console.error('type4');
            sheet.beforeAndAfter.after.end = activatedBeforeAndAfter.after.end;
            sheet.beforeAndAfter.after.start = sheet.beforeAndAfter.after.end;
         }
         else {
            console.error('type5');
         }
      }
      else {
         console.error('type6');
      }
      sheet.beforeAndAfter.after.cLength = activatedBeforeAndAfter.after.cLength;
      sheet.beforeAndAfter.before = sheet.beforeAndAfter.after;
      if(savedSel != null) {
         savedSel[0].range.start = sheet.beforeAndAfter.after.start;
         savedSel[0].range.end = sheet.beforeAndAfter.after.end;

         console.log(savedSel[0].range.start, savedSel[0].range.end);
         rangy.getSelection().restoreCharacterRanges(this, savedSel);
      }
    });
 }
})(jQuery);
