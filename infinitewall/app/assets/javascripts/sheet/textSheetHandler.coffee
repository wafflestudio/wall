define ["./sheetHandler", "constants"], (SheetHandler, Constants) ->
  class TextSheetHandler extends SheetHandler
    onResizeMouseMove: (e) =>
      #super e
      @onResizeMouseMoveSuper(e)

      newHeight = @sheet.ih
      newWidth = @sheet.iw
      newX = @sheet.x
      newY = @sheet.y

      switch @resizeType
        when "resizeBottom"
          newHeight = (@startHeight + e.pageY - @deltay) / stage.zoom
        when "resizeTop"
          newY = (@starty + e.pageY - @deltay) / stage.zoom
          newHeight = (@startHeight - e.pageY + @deltay) / stage.zoom
        when "resizeRight"
          newWidth = (@startWidth + e.pageX - @deltax) / stage.zoom
        when "resizeLeft"
          newX = (@startx + e.pageX - @deltax) / stage.zoom
          newWidth = (@startWidth - e.pageX + @deltax) / stage.zoom
        when "resizeBottomRight"
          newWidth = (@startWidth + e.pageX - @deltax) / stage.zoom
          newHeight = (@startHeight + e.pageY - @deltay) / stage.zoom
        when "resizeBottomLeft"
          newX = (@startx + e.pageX - @deltax) / stage.zoom
          newWidth = (@startWidth - e.pageX + @deltax) / stage.zoom
          newHeight = (@startHeight + e.pageY - @deltay) / stage.zoom
        when "resizeTopLeft"
          newX = (@startx + e.pageX - @deltax) / stage.zoom
          newY = (@starty + e.pageY - @deltay) / stage.zoom
          newWidth = (@startWidth - e.pageX + @deltax) / stage.zoom
          newHeight = (@startHeight - e.pageY + @deltay) / stage.zoom
        when "resizeTopRight"
          newY = (@starty + e.pageY - @deltay) / stage.zoom
          newWidth = (@startWidth + e.pageX - @deltax) / stage.zoom
          newHeight = (@startHeight - e.pageY + @deltay) / stage.zoom

      if newWidth < Constants.minSize and newHeight < Constants.minSize
        @sheet.ih = Constants.minSize
        @sheet.iw = Constants.minSize

      else if newWidth < Constants.minSize
        @sheet.ih = newHeight
        @sheet.iw = Constants.minSize
        @sheet.y = newY
        switch @resizeType
          when "resizeRight", "resizeBottomRight", "resizeTop", "resizeBottom" then @sheet.x = newX

      else if newHeight < Constants.minSize
        @sheet.x = newX
        @sheet.iw = newWidth
        @sheet.ih = Constants.minSize
        switch @resizeType
          when "resizeBottom", "resizeRight", "resizeLeft", "resizeBottomLeft", "resizeBottomRight" then @sheet.y = newY

      else
        @sheet.x = newX
        @sheet.y = newY
        @sheet.iw = newWidth
        @sheet.ih = newHeight

    onResizeTouchMove: (e) =>
      @sheet.iw = (@startWidth + e.originalEvent.pageX - @deltax) / stage.zoom
      @sheet.ih = (@startHeight + e.originalEvent.pageY - @deltay) / stage.zoom
