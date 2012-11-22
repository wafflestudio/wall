class window.TextSheetHandler extends SheetHandler

  onMouseMove: (e) =>
    #if $("*:focus").is(".sheetTitle") or $("*:focus").is(".sheetTextField")
      #return
    super e

  onResizeMouseMove: (e) =>
    newW = (@startWidth + e.pageX - @deltax) / glob.zoomLevel
    newH = (@startHeight + e.pageY - @deltay) / glob.zoomLevel
    @sheet.setWH(newW, newH)
