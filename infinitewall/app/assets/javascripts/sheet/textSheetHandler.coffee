class window.TextSheetHandler extends SheetHandler
  onResizeMouseMove: (e) =>
    super e
    @sheet.iw((@startWidth + e.pageX - @deltax) / stage.zoom)
    @sheet.ih((@startHeight + e.pageY - @deltay) / stage.zoom)

  onResizeTouchMove: (e) =>
    @sheet.iw((@startWidth + e.originalEvent.pageX - @deltax) / stage.zoom)
    @sheet.ih((@startHeight + e.originalEvent.pageY - @deltay) / stage.zoom)
