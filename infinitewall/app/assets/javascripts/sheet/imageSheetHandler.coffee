class window.ImageSheetHandler extends SheetHandler
  imgWidth: 0
  imgHeight: 0

  constructor: (params) ->
    super params
    @imgWidth = @sheet.iw()
    @imgHeight = @sheet.ih()

  onResizeMouseMove: (e) =>
    
    dX = e.pageX - @deltax
    dY = e.pageY - @deltay
    ratio = @imgWidth / @imgHeight

    if Math.abs(dX / dY) > ratio
      @sheet.iw((@startWidth + dX) / glob.zoomLevel)
      @sheet.ih((@startHeight + dX / ratio) / glob.zoomLevel)
    else
      @sheet.iw((@startWidth + dY * ratio) / glob.zoomLevel)
      @sheet.ih((@startHeight + dY) / glob.zoomLevel)
