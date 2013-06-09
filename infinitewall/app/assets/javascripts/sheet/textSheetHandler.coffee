define ["./sheetHandler"], (SheetHandler) ->
  class TextSheetHandler extends SheetHandler
    onResizeMouseMove: (e) =>
      super e

      switch @resizeType
        when "resizeBottom"
          @sheet.ih = (@startHeight + e.pageY - @deltay) / stage.zoom
        when "resizeTop"
          @sheet.y = (@starty + e.pageY - @deltay) / stage.zoom
          @sheet.ih = (@startHeight - e.pageY + @deltay) / stage.zoom
        when "resizeRight"
          @sheet.iw = (@startWidth + e.pageX - @deltax) / stage.zoom
        when "resizeLeft"
          @sheet.x = (@startx + e.pageX - @deltax) / stage.zoom
          @sheet.iw = (@startWidth - e.pageX + @deltax) / stage.zoom
        when "resizeBottomRight"
          @sheet.iw = (@startWidth + e.pageX - @deltax) / stage.zoom
          @sheet.ih = (@startHeight + e.pageY - @deltay) / stage.zoom
        when "resizeBottomLeft"
          @sheet.x = (@startx + e.pageX - @deltax) / stage.zoom
          @sheet.iw = (@startWidth - e.pageX + @deltax) / stage.zoom
          @sheet.ih = (@startHeight + e.pageY - @deltay) / stage.zoom
        when "resizeTopLeft"
          @sheet.x = (@startx + e.pageX - @deltax) / stage.zoom
          @sheet.y = (@starty + e.pageY - @deltay) / stage.zoom
          @sheet.iw = (@startWidth - e.pageX + @deltax) / stage.zoom
          @sheet.ih = (@startHeight - e.pageY + @deltay) / stage.zoom
        when "resizeTopRight"
          @sheet.y = (@starty + e.pageY - @deltay) / stage.zoom
          @sheet.iw = (@startWidth + e.pageX - @deltax) / stage.zoom
          @sheet.ih = (@startHeight - e.pageY + @deltay) / stage.zoom

    onResizeTouchMove: (e) =>
      @sheet.iw = (@startWidth + e.originalEvent.pageX - @deltax) / stage.zoom
      @sheet.ih = (@startHeight + e.originalEvent.pageY - @deltay) / stage.zoom
