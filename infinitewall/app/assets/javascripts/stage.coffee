globglob = new ->
    this.activeSheet = null
    this.hoverSheet = null
    this.rightClick = false
    this.zoomLevel = 1

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
        text = if file.name.length > 25 then file.name.substring(0, 22) + "..." else file.name
        data.context = statusbar.addStatus("#{text}", "0%")
        data.submit()
    progress : (e, data) ->
      progress = parseInt(data.loaded / data.total * 100) + "%"
      data.context.changeRightText(progress)
    drop : (e, data) ->
      #$.each data.files, (index, file) ->
        #console.log index
    progressall : (e, data) ->
      #progress = parseInt (data.loaded / data.total * 100)
      #console.log e
      #console.log progress + "%, " + data.bitrate / (8 * 1024 * 1024)
    done : (e, data) ->
      $.each(data.result, (index, file) ->
        name = if file.name.length > 25 then file.name.substring(0, 18) + "..." else file.name
        data.context.changeText("Loading " + name, "")
        ImageSheet.create file.name.replace(/\.[^/.]+$/, ""), "/assets/files/#{file.name}", =>
          statusbar.removeStatus(data.context.id, 0)
          data.context = null
      )
  }
