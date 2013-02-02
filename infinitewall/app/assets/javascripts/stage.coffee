globglob = new ->
    this.activeSheet = null
    this.hoverSheet = null
    this.linkFromSheet = null
    this.leftClick = false
    this.rightClick = false
    this.zoomLevel = 1

    this.scaleLayerX = 0
    this.scaleLayerY = 0
    this.moveID = null

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
  minimap.refresh()

$ ->
  window.glob = globglob
  window.wall = new Wall()
  window.minimap = new Minimap()
  window.menu = new Menu()
  window.statusbar = new Statusbar()
  
  #wall.setName("testWallName")

  $(document).bind "contextmenu", ->
    return false
  
  $('#fileupload').fileupload  {
    dataType: 'json'
    #process: [
      #{
        #action: 'load'
        #fileTypes: /^image\/(gif|jpeg|png)$/
        #maxFileSize: 20000000
      #}
    #]
    #sequentialUploads: true
    add: (e, data) ->
      $.each data.files, (index, file) ->
        data.context = statusbar.addStatus("#{file.name}", "0%")
        data.submit()
    change: (e, data) ->
      statusbar.instantStatus("Hint: Drag and dropping works! :)", 3500)
      console.log "change dammit"

    progress : (e, data) ->
      progress = parseInt(data.loaded / data.total * 100) + "%"
      data.context.changeRightText(progress)
    drop :(e, data) ->
      #$.each data.files, (index, file) ->
        #console.log index
    progressall : (e, data) ->
      #progress = parseInt (data.loaded / data.total * 100)
      #console.log e
      #console.log progress + "%, " + data.bitrate / (8 * 1024 * 1024)
    done : (e, data) ->
      $.each(data.result, (index, file) ->
        data.context.changeText("Loading " + file.name, "")
        ImageSheet.create file.name.replace(/\.[^/.]+$/, ""), "/assets/files/#{file.name}", =>
          statusbar.removeStatus(data.context.id, 0)
          data.context = null
      )
  }
