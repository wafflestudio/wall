class window.TextSheetHandler extends SheetHandler
  onResizeMouseMove: (e) =>
    super e
    @sheet.iw((@startWidth + e.pageX - @deltax) / glob.zoomLevel)
    @sheet.ih((@startHeight + e.pageY - @deltay) / glob.zoomLevel)
