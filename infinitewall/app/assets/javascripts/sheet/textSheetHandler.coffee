class window.TextSheetHandler extends SheetHandler

  onResizeMouseMove: (e) =>
    newW = (@startWidth + e.pageX - @deltax) / glob.zoomLevel
    newH = (@startHeight + e.pageY - @deltay) / glob.zoomLevel
    @sheet.setWH(newW, newH)
