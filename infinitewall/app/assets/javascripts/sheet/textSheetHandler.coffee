class window.TextSheetHandler extends SheetHandler
  onResizeMouseMove: (e) =>
    super e
    @sheet.iw((@startWidth + e.pageX - @deltax) / glob.zoomLevel)
    @sheet.ih((@startHeight + e.pageY - @deltay) / glob.zoomLevel)

  onResizeTouchMove: (e) =>
    @sheet.iw((@startWidth + e.originalEvent.pageX - @deltax) / glob.zoomLevel)
    @sheet.ih((@startHeight + e.originalEvent.pageY - @deltay) / glob.zoomLevel)
