//variable
var clipboard = {
  state: false,
  data: null,
  backup: null
}

//handlers
function copyHandler(element) {
  function onCutAndCopy(e) {
    console.log('on copy/cut');

    sheet = $(this).parent(".sheetBox");

    //현재는 text sheet 경우만 고려
    sheet_title = $(sheet).find(".sheetTopBar h1");
    sheet_content = $($(sheet).find(".sheetText div.redactor_editor")[0]);
    data = {
      'type': 'text',
      'title': sheet_title.html(),
      'content': sheet_content.html()
    }

    console.log(data);
    clipboard.data = data;
    clipboard.state = true;

    if(e.type == 'cut') {
      id = sheet.attr('id').substr(5);
      sheet.trigger("remove", {id: id});
    }

  }

  $(element).children().on('copy cut', onCutAndCopy);
}

//singletone?
function pasteHandler(element) {
  var doFakePaste = false;

  function onKeyDown(e) {
    // These browser work with the real paste event
    if ($.client.browser === "Chrome")
      return;
    if ($.client.os === "Windows" && $.client.browser === "Safari")
      return;
    
    // Check for patse keydown event
    if (!doFakePaste && ($.client.os === "Mac" && e.which == 86 && e.metaKey) || ($.client.os !== "Mac" && e.which == 86 && e.ctrlKey)) {
      doFakePaste = true;
      // got a paste
      if (!$("*:focus").is("input") && !$("*:focus").is("textarea")) { 
        // Focus the offscreen editable
        $('#TribblePaste').focus();
        
        // Opera doesn't support onPaste events so we have
        // to use a timeout to get the paste
        if ($.client.browser === "Opera") {
          setTimeout(function() {
            doFakePaste = false;
            var html = $('#TribblePaste').html();
            var text = $('#TribblePaste').text();
            if (text == '') text = $('#TribblePaste').val();

            console.log("o " + html);
            console.log("o " + text);

            $('#TribblePaste').val('');
            $('#TribblePaste').text('');
            $('#TribblePaste').blur();
          }, 1);
        }
      }
    }
  }

  function onPaste(e) {
    //check if inner copy object exist
    if(clipboard.state) {
      //random creation for text sheet
      var x = Math.random()*500
      var y = Math.random()*400
      var w = 300
      var h = 300
      var text = clipboard.data.content
      wallSocket.send({action:"create", params:{x:x, y:y, width:w, height:h, text:text}})
    
      //state to false
      clipboard.state = false;

      return;
    }

    // Firefox is not supported - they don't
    // expose the real clipboard
    if ($.client.browser === 'Firefox')
      return;
    
    // real pasteing
    var html = '';
    var text = '';
    if (window.clipboardData) { // IE  
      text = window.clipboardData.getData("Text");
    } else if (e.clipboardData && e.clipboardData.getData) { // Standard
      text = e.clipboardData.getData('text/plain');
      html = e.clipboardData.getData('text/html');
    } else if (e.originalEvent.clipboardData && e.originalEvent.clipboardData.getData) { // jQuery
      text = e.originalEvent.clipboardData.getData('text/plain');
      html = e.originalEvent.clipboardData.getData('text/html');
    }

    console.log("1 " + html);
    console.log("1 " + text);
  }

  // Setup the offscreen paste capture area
  $('<div contenteditable id="TribblePaste"></div>').css({
    'position': 'absolute',
    'top': '-100000px',
    'width': '100px',
    'height': '100px'
  }).on('paste', function(e) {
    setTimeout(function() {
      doFakePaste = false;
      var html = $('#TribblePaste').html();
      var text = $('#TribblePaste').text();
      if (text == '') text = $('#TribblePaste').val();

      console.log("2 " + html);
      console.log("2 " + text);

      $('#TribblePaste').val('');
      $('#TribblePaste').text('');
      $('#TribblePaste').blur();
    }, 1);
  });

  $(element).on('keydown', onKeyDown).on('paste', onPaste);
}

//attach event on wall ready
$(document).on('wallready', function() {
    $.each($(".sheetBox"), function(key, val) {
      copyHandler(val);
    });

    pasteHandler($("#wall"));
});



// OS detection plugin
// http://www.stoimen.com/blog/2009/07/16/jquery-browser-and-os-detection-plugin/
(function() {
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
