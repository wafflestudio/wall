#variables

globglob = new ->
    this.activeSheet = null
    this.hoverSheet = null
    this.rightClick = false
    this.zoomLevel = 1

    this.minimapToggled = 1
    this.rightBarOffset = 267 + 80 + 30 # 80은 위에 userList, 30은 밑에 input
    
    this.scaleLayerXPos = 0
    this.scaleLayerYPos = 0

window.contentTypeEnum = {
  text: "text",
  image: "image"
}
window.sheets = {}
window.miniSheets = {}

#default functions for socket receive
window.createSheet = (id, params, timestamp) ->
  if params.contentType == window.contentTypeEnum.text
    new TextSheet($.extend(params, {id : id}), timestamp)
  else if params.contentType == window.contentTypeEnum.image
    new ImageSheet($.extend(params, {id : id}))

toggleMinimap = ->
  if glob.minimapToggled
    glob.minimapToggled = 0
    $('#miniMap').transition {x: '220'}, 300, toggleMinimapFinished
  else
    glob.minimapToggled = 1
    $('#chatWindow').transition {height: '-=190'}, 300, toggleMinimapFinished

toggleMinimapFinished = ->
  if glob.minimapToggled
    $('#miniMap').transition {x: '0'}, 300
    glob.rightBarOffset += 190
  else
    $('#chatWindow').transition {height: '+=190'}, 300
    glob.rightBarOffset -= 190

$(window).resize ->
  $('#chatWindow').height ($(window).height() - glob.rightBarOffset)
  minimap.refresh()

$ () ->

  window.glob = globglob
  window.wall = new Wall()
  window.minimap = new Minimap()
  
  $(document).bind "contextmenu", ->
    return false

  $("#zoomLevelText").dblclick ->
    console.log "Implement me!"

  loadingSheet = null
  
  $('#fileupload').fileupload  {
    dataType : 'json',
    drop : (e, data) ->
      console.log "Image dropped!"
    progressall : (e, data) ->
      progress = parseInt (data.loaded / data.total * 100)
      console.log progress + "%, " + data.bitrate / (8 * 1024 * 1024)
    done : (e, data) ->
      $.each(data.result, (index, file) ->
        $(loadingSheet).trigger 'remove'
        ImageSheet.create("/assets/files/#{file.name}")
      )
  }

  $('.createBtn').on('click', () ->
    if $(this).attr('rel') == 'text'
      TextSheet.create("text")
  )

  $('#minimapBtn').click toggleMinimap
  $('#chatWindow').height ($(window).height() - glob.rightBarOffset)
  $('#currentWallNameText').text "First wall"
