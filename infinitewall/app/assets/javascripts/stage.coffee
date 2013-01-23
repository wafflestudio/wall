#variables

globglob = new ->
    this.activeSheet = null
    this.hoverSheet = null
    this.rightClick = false
    this.zoomLevel = 1

    this.minimapToggled = 1
    
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

window.createSheetLink = (params, timestamp) ->
  fromSheet = sheets[params.from_id]
  fromSheet.setLink(params)

$(window).resize ->
  #$('#chatWindow').height ($(window).height() - glob.rightBarOffset)
  minimap.refresh()

$ () ->

  window.glob = globglob
  window.wall = new Wall()
  window.minimap = new Minimap()
  loadingSheet = null
  
  $(document).bind "contextmenu", ->
    return false

  
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

  $('#newSheetButton').on 'click', () ->
    if $(this).attr('rel') == 'text'
      TextSheet.create("text")

  $('#deleteSheetButton').on 'click', () ->
    console.log glob.activeSheet
    glob.activeSheet.socketRemove() if glob.activeSheet
    wall.deactivateDelete()

  #$('#chatWindow').height ($(window).height() - glob.rightBarOffset)
  #$('#currentWallNameText').text "First wall"
