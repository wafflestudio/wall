define ["jquery"], ($) ->
  class TemplateFactory
    @imageTemplate: ->
      "<div class='sheetBox' tabindex='-1'>
        <div class='sheet' contentType='image'>
          <div class='sheetTopBar'>
            <h1 class='sheetTitle' contenteditable='true'></h1>
          </div>
          <div class='sheetImage'></div>
          <div class='resizeHandleContainer'>
            <div class='resizeHandle resizeEdge resizeTop'></div>
            <div class='resizeHandle resizeEdge resizeBottom'></div>
            <div class='resizeHandle resizeEdge resizeLeft'></div>
            <div class='resizeHandle resizeEdge resizeRight'></div>
            <div class='resizeHandle resizeCorner resizeTopLeft'></div>
            <div class='resizeHandle resizeCorner resizeTopRight'></div>
            <div class='resizeHandle resizeCorner resizeBottomLeft'></div>
            <div class='resizeHandle resizeCorner resizeBottomRight'></div>
          </div>
        </div>
      </div>"

    @textTemplate: ->
      "<div class='sheetBox' tabindex='-1'>
          <div class='sheet' contentType='text'>
            <!--<div class='sheetTopBar'>-->
              <!--<h1 class='sheetTitle' contenteditable='true'></h1>-->
            <!--</div>-->
            <div class='sheetText'>
              <div class='sheetTextField' data-placeholder=' Click or tap to edit '>
              </div>
            </div>
            <div class='resizeHandleContainer'>
              <div class='resizeHandle resizeEdge resizeTop'></div>
              <div class='resizeHandle resizeEdge resizeBottom'></div>
              <div class='resizeHandle resizeEdge resizeLeft'></div>
              <div class='resizeHandle resizeEdge resizeRight'></div>
              <div class='resizeHandle resizeCorner resizeTopLeft'></div>
              <div class='resizeHandle resizeCorner resizeTopRight'></div>
              <div class='resizeHandle resizeCorner resizeBottomLeft'></div>
              <div class='resizeHandle resizeCorner resizeBottomRight'></div>
            </div>
          </div>
        </div>"

    @videoTemplate: ->
      "<div class='sheetBox' tabindex='-1'>
        <div class='sheet' contentType='image'>
          <div class='sheetTopBar'>
            <h1 class='sheetTitle' contenteditable='true'> New Sheet </h1>
          </div>
          <div class='sheetVideo'></div>
          <div class='resizeHandle'></div>
        </div>
      </div>"

    @searchTemplate: ->
      "<div class='searchResult'>
          <b id='title'> </b>
          <span id='content'> </span>
        </div>"

    @makeTemplate: (type) ->
      switch type
        when "imageSheet" then @imageTemplate()
        when "textSheet" then @textTemplate()
        when "videoSheet" then @videoTemplate()
        when "search" then @searchTemplate()


