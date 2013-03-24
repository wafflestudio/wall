#variable
clipboard = {
  state: false,
  data: null,
  backup: null
}

#handlers
copyHandler = (wall) ->
  onKeyDown = (e) ->
    element = stage.currentSheet
    if (($.client.os == "Mac" && e.which == 67 && e.metaKey) || ($.client.os != "Mac" && e.which == 67 && e.ctrlKey))
      $(element).trigger('copy')
    else if (($.client.os == "Mac" && e.which == 88 && e.metaKey) || ($.client.os != "Mac" && e.which == 88 && e.ctrlKey))
      $(element).trigger('cut')

  onCutAndCopy = (e) ->
    element = stage.currentSheet
    console.log('on copy/cut')
    if ($("*:focus").is(".sheetTitle") || $("*:focus").is(".sheetTextField"))
      return

    sheet = $(element)

    #현재는 text sheet 경우만 고려
    sheet_inner = $(sheet).find(".sheet")
    sheet_title = $(sheet).find(".sheetTopBar h1")

    sheet_contentType = sheet_inner.attr('contentType')
    if sheet_contentType == 'text'
      sheet_content = $(sheet).find(".sheetText").find(".sheetTextField").html()
    else if sheet_contentType == 'image'
      sheet_content = $(sheet).find(".sheetImage").css('background-image').split("\"")[1]

    data = {
      'title': sheet_title.html(),
      'width': sheet_inner.width(),
      'height': sheet_inner.height(),
      'contentType': sheet_contentType,
      'content': sheet_content
    }

    console.log(data)
    clipboard.data = data
    clipboard.state = true

    if(e.type == 'cut')
      id = sheet.attr('id').substr(5)
      sheet.trigger("remove", {id: id})

  $(wall).on('keydown', onKeyDown).on('copy cut', onCutAndCopy)

pasteHandler = (element) ->
  isTextField = false
  doFakePaste = false

  onKeyDown = (e) ->
    if ($("*:focus").is(".sheetTitle") || $("*:focus").is(".sheetTextField"))
      isTextField = true
      return

    #These browser work with the real paste event
    if ($.client.browser == "Chrome")
      return
    if ($.client.os == "Windows" && $.client.browser == "Safari")
      return
    
    #Check for paste keydown event
    if (!doFakePaste && ($.client.os == "Mac" && e.which == 86 && e.metaKey) || ($.client.os != "Mac" && e.which == 86 && e.ctrlKey))
      doFakePaste = true
      #got a paste
      if (!$("*:focus").is("input") && !$("*:focus").is("textarea"))
        #Focus the offscreen editable
        $('#wallPasteArea').focus()
        
        #Opera doesn't support onPaste events so we have to use a timeout to get the paste
        if ($.client.browser == "Opera")
          setTimeout(() ->
            doFakePaste = false
            html = $('#wallPasteArea').html()
            text = $('#wallPasteArea').text()
            if (text == '')
              text = $('#wallPasteArea').val()

            console.log("o " + html)
            console.log("o " + text)

            $('#wallPasteArea').val('')
            $('#wallPasteArea').text('')
            $('#wallPasteArea').blur()
          , 1)

  onPaste = (e) ->
    #check if inner copy object exist
    console.log("on paste")

    if isTextField
      isTextField = false
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

      wallSocket.sendAction({action:"create", params:{x:x, y:y, width:w, height:h, title:title,contentType:contentType, content:content}})

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

    #image only for now
    image_src = parseImageSrc(html)
    createImageSheet(image_src)

  #Setup the offscreen paste capture area
  $('#wallPasteArea').css({
    'position': 'absolute',
    'top': '-100000px',
    'width': '100px',
    'height': '100px'
  }).on('paste', (e) ->
    setTimeout(() ->
      doFakePaste = false
      html = $('#wallPasteArea').html()
      text = $('#wallPasteArea').text()
      if (text == '')
        text = $('#wallPasteArea').val()

      console.log("2 " + html)
      console.log("2 " + text)

      #image only for now
      image_src = parseImageSrc(html)
      createImageSheet(image_src)

      $('#wallPasteArea').val('')
      $('#wallPasteArea').text('')
      $('#wallPasteArea').blur()
    , 1)
  )

  $(element).on('keydown', onKeyDown).on('paste', onPaste)
  #$(element).on('drop', onKeyDown).on('drop', onPaste)

window.copyHandler = copyHandler
window.pasteHandler = pasteHandler

#private functions
parseImageSrc = (htmlstr) ->
  $('#wallPasteArea').html(htmlstr)
  images = $('#wallPasteArea').find('img')
  image_src = null

  if(images.length == 1)
    image_src = images.attr('src')
  
  $('#wallPasteArea').html('')
  $('#wallPasteArea').text('')
  return image_src

createImageSheet = (image_src) ->
  if(image_src != null)
    ImageSheet.create(image_src)

#attach event on wall ready
$(document).on('wallready', () ->
  copyHandler($("#wall"))
  pasteHandler($("#wall"))
)
