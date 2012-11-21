class window.ImageSheetHandler extends SheetHandler
  imgWidth: 0
  imgHeight: 0

  constructor: (params) ->
    super params
    @imgWidth = @sheet.getWH().w
    @imgHeight = @sheet.getWH().h

  onResizeMouseMove: (e) =>
    
    dX = e.pageX - @deltax
    dY = e.pageY - @deltay
    ratio = @imgWidth / @imgHeight

    if Math.abs(dX / dY) > ratio
      newW = (@startWidth + dX) / glob.zoomLevel
      newH = (@startHeight + dX / ratio) / glob.zoomLevel
    else
      newW = (@startWidth + dY * ratio) / glob.zoomLevel
      newH = (@startHeight + dY) / glob.zoomLevel

    @sheet.setWH(newW, newH)
