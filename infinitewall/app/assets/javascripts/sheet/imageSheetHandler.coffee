define ["./sheetHandler"], (SheetHandler) ->
  class ImageSheetHandler extends SheetHandler
    imgWidth: 0
    imgHeight: 0

    constructor: (params) ->
      super params
      @sheet.element.on 'mousedown', '.sheetImage', (e) -> e.preventDefault()
      @imgWidth = @sheet.iw
      @imgHeight = @sheet.ih

    onResizeMouseMove: (e) =>
      @onResizeMouseMoveSuper e

      dX = e.pageX - @deltax
      dY = e.pageY - @deltay
      ratio = @imgWidth / @imgHeight

      if Math.abs(dX / dY) > ratio
        @sheet.iw = (@startWidth + dX) / stage.zoom
        @sheet.ih = (@startHeight + dX / ratio) / stage.zoom
      else
        @sheet.iw = (@startWidth + dY * ratio) / stage.zoom
        @sheet.ih = (@startHeight + dY) / stage.zoom
