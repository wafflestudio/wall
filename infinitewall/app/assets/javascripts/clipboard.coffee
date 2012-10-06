#variable
clipboard = {
  state: false,
  data: null,
  backup: null
}

#handlers
copyHandler = (wall) ->
  onKeyDown = (e) ->
    element = glob.currentSheet
    console.log(element)
    if (($.client.os == "Mac" && e.which == 67 && e.metaKey) || ($.client.os != "Mac" && e.which == 67 && e.ctrlKey))
      $(element).trigger('copy')
    else if (($.client.os == "Mac" && e.which == 88 && e.metaKey) || ($.client.os != "Mac" && e.which == 88 && e.ctrlKey))
      $(element).trigger('cut')

  onCutAndCopy = (e) ->
    element = glob.currentSheet
    console.log('on copy/cut')
    if ($("*:focus").is(".sheetTitle") || $("*:focus").is(".redactor_editor"))
      return

    sheet = $(element)

    #현재는 text sheet 경우만 고려
    sheet_inner = $(sheet).find(".sheet")
    sheet_title = $(sheet).find(".sheetTopBar h1")
    sheet_content = $($(sheet).find(".sheetText div.redactor_editor")[0])

    data = {
      'type': 'text',
      'title': sheet_title.html(),
      'width': sheet_inner.width(),
      'height': sheet_inner.height(),
      'contentType': sheet_inner.attr('contentType'),
      'content': sheet_content.html()
    }

    console.log(data)
    clipboard.data = data
    clipboard.state = true

    if(e.type == 'cut')
      id = sheet.attr('id').substr(5)
      sheet.trigger("remove", {id: id})

  $(wall).on('keydown', onKeyDown).on('copy cut', onCutAndCopy)

pasteHandler = (element) ->
  doFakePaste = false

  onKeyDown = (e) ->
    console.log('w')
    #These browser work with the real paste event
    if ($.client.browser == "Chrome")
      return
    if ($.client.os == "Windows" && $.client.browser == "Safari")
      return
    
    #Check for patse keydown event
    if (!doFakePaste && ($.client.os == "Mac" && e.which == 86 && e.metaKey) || ($.client.os != "Mac" && e.which == 86 && e.ctrlKey))
      doFakePaste = true
      #got a paste
      if (!$("*:focus").is("input") && !$("*:focus").is("textarea"))
        #Focus the offscreen editable
        $('#WallPasteArea').focus()
        
        #Opera doesn't support onPaste events so we have to use a timeout to get the paste
        if ($.client.browser == "Opera")
          setTimeout(() ->
            doFakePaste = false
            html = $('#WallPasteArea').html()
            text = $('#WallPasteArea').text()
            if (text == '')
              text = $('#WallPasteArea').val()

            console.log("o " + html)
            console.log("o " + text)

            $('#WallPasteArea').val('')
            $('#WallPasteArea').text('')
            $('#WallPasteArea').blur()
          , 1)

  onPaste = (e) ->
    #check if inner copy object exist
    console.log("on paste")

    if ($("*:focus").is(".sheetTitle") || $("*:focus").is(".redactor_editor"))
      return

    if clipboard.state
      x = Math.random()*500
      y = Math.random()*400
      w = 300
      h = 300

      w = clipboard.data.width
      h = clipboard.data.height
      title = clipboard.data.title
      contentType = clipboard.data.contentType
      content = clipboard.data.content

      wallSocket.send({action:"create", params:{x:x, y:y, width:w, height:h, title:title,contentType:contentType, content:content}})

      #state to false
      clipboard.state = false
      return

    #Firefox is not supported - they don't expose the real clipboard
    if ($.client.browser == 'Firefox')
      return
    
    # real pasteing
    html = ''
    text = ''
    if (window.clipboardData) #IE
      text = window.clipboardData.getData("Text")
    else if (e.clipboardData && e.clipboardData.getData) #Standard
      text = e.clipboardData.getData('text/plain')
      html = e.clipboardData.getData('text/html')
    else if (e.originalEvent.clipboardData && e.originalEvent.clipboardData.getData) #jQuery
      text = e.originalEvent.clipboardData.getData('text/plain')
      html = e.originalEvent.clipboardData.getData('text/html')

    console.log("1 " + html)
    console.log("1 " + text)

  #Setup the offscreen paste capture area
  $('<div contenteditable id="WallPasteArea"></div>').css({
    'position': 'absolute',
    'top': '-100000px',
    'width': '100px',
    'height': '100px'
  }).on('paste', (e) ->
    setTimeout(() ->
      doFakePaste = false
      html = $('#WallPasteArea').html()
      text = $('#WallPasteArea').text()
      if (text == '')
        text = $('#WallPasteArea').val()

      console.log("2 " + html)
      console.log("2 " + text)

      $('#WallPasteArea').val('')
      $('#WallPasteArea').text('')
      $('#WallPasteArea').blur()
    , 1)
  )

  $(element).on('keydown', onKeyDown).on('paste', onPaste)

window.copyHandler = copyHandler
window.pasteHandler = pasteHandler

#attach event on wall ready
$(document).on('wallready', () ->
  copyHandler($("#wall"))
  pasteHandler($("#wall"))
)


###
#OS detection plugin - http://www.stoimen.com/blog/2009/07/16/jquery-browser-and-os-detection-plugin/
(() ->
  var BrowserDetect = {
    init: function() {
      this.browser = this.searchString(this.dataBrowser) || "An unknown browser";
      this.version = this.searchVersion(navigator.userAgent) || this.searchVersion(navigator.appVersion) || "an unknown version";
      this.OS = this.searchString(this.dataOS) || "an unknown OS";
    },
    searchString: function(data) {
      for (var i = 0; i < data.length; i++) {
        var dataString = data[i].string;
        var dataProp = data[i].prop;
        this.versionSearchString = data[i].versionSearch || data[i].identity;
        if (dataString) {
         if (dataString.indexOf(data[i].subString) != -1) return data[i].identity;
        } else if (dataProp) return data[i].identity;
      }
    },
    searchVersion: function(dataString) {
      var index = dataString.indexOf(this.versionSearchString);
      if (index == -1) return;
      return parseFloat(dataString.substring(index + this.versionSearchString.length + 1));
    },
    dataBrowser: [
        {
        string: navigator.userAgent,
        subString: "Chrome",
        identity: "Chrome"},
    {
        string: navigator.userAgent,
        subString: "OmniWeb",
        versionSearch: "OmniWeb/",
        identity: "OmniWeb"},
    {
        string: navigator.vendor,
        subString: "Apple",
        identity: "Safari",
        versionSearch: "Version"},
    {
        prop: window.opera,
        identity: "Opera"},
    {
        string: navigator.vendor,
        subString: "iCab",
        identity: "iCab"},
    {
        string: navigator.vendor,
        subString: "KDE",
        identity: "Konqueror"},
    {
        string: navigator.userAgent,
        subString: "Firefox",
        identity: "Firefox"},
    {
        string: navigator.vendor,
        subString: "Camino",
        identity: "Camino"},
    { // for newer Netscapes (6+)
        string: navigator.userAgent,
        subString: "Netscape",
        identity: "Netscape"},
    {
        string: navigator.userAgent,
        subString: "MSIE",
        identity: "Explorer",
        versionSearch: "MSIE"},
    {
        string: navigator.userAgent,
        subString: "Gecko",
        identity: "Mozilla",
        versionSearch: "rv"},
    { // for older Netscapes (4-)
        string: navigator.userAgent,
        subString: "Mozilla",
        identity: "Netscape",
        versionSearch: "Mozilla"}
    ],
    dataOS: [
        {
        string: navigator.platform,
        subString: "Win",
        identity: "Windows"},
    {
        string: navigator.platform,
        subString: "Mac",
        identity: "Mac"},
    {
        string: navigator.userAgent,
        subString: "iPhone",
        identity: "iPhone/iPod"},
    {
        string: navigator.platform,
        subString: "Linux",
        identity: "Linux"}
    ]

  };

  BrowserDetect.init();

  window.$.client = {
      os: BrowserDetect.OS,
      browser: BrowserDetect.browser
  };

})();
###
