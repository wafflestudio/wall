class window.Menu
  constructor: ->
    @profile = $('#profilePic')
    @logoff = $('#logoutButton')
    @newSheet = $('#newSheetButton')
    @newSheetContainer = $('#newSheetContainer')
    @newSheetButtons = $('.newSheetButtons')
    @deleteSheet = $('#deleteSheetButton')
    @minimap = $('#minimapButton')
    @tellButton = $('#tellButton')
    @menubar = $('#menuBar')
    @menubar.on 'mousedown', (e) -> e.preventDefault()
    @menubar.css('x', 0) # ios에서 메뉴바 찌그러지는거 막음

    @newSheetButtons.click ->
      switch $(this).attr('rel')
        when 'text'
          TextSheet.create("text")
        when 'image'
          $("#fileupload").click()
        when 'video'
          new VideoSheet()
          console.log "videovideo"

    @deleteSheet.click =>
      stage.activeSheet.socketRemove() if stage.activeSheet
      @deactivateDelete()

    @tellButton.click -> stage.activeSheet.glow()

    @newSheet.click => @newSheetContainer.slideToggle(300)
    @minimap.click -> minimap.toggle()

  activateDelete: ->
    @deleteSheet.css('background-image', 'url(/assets/images/delete_red.png)')
    
  deactivateDelete: ->
    @deleteSheet.css('background-image', 'url(/assets/images/delete_white.png)')
