class window.Menu
  constructor: ->
    @profile = $('#profilePic')
    @logoff = $('#logoutButton')
    @newSheet = $('#newSheetButton')
    @newSheetContainer = $("#newSheetContainer")
    @newSheetButtons = $('.newSheetButtons')
    @deleteSheet = $('#deleteSheetButton')
    @minimap = $('#minimapButton')
    @menubar = $('#menuBar')
    @menubar.on 'mousedown', (e) -> e.preventDefault()

    @newSheetButtons.click ->
      switch $(this).attr('rel')
        when 'text'
          TextSheet.create("text")
        when 'image'
          $("#fileupload").click()

    @deleteSheet.click =>
      glob.activeSheet.socketRemove() if glob.activeSheet
      @deactivateDelete()

    @newSheet.click => @newSheetContainer.slideToggle(300)
    @minimap.click -> minimap.toggle()

  activateDelete: ->
    @deleteSheet.css('background-image', 'url(/assets/images/delete_red.png)')
    
  deactivateDelete: ->
    @deleteSheet.css('background-image', 'url(/assets/images/delete_white.png)')
