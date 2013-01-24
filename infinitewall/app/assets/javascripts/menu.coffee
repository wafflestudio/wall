class window.Menu
  menubar: null
  profile: null
  logout: null
  newSheet: null
  deleteSheet: null
  minimap: null

  constructor: ->
    @profile = $('#profilePic')
    @logoff = $('#logoutButton')
    @newSheet = $('#newSheetButton')
    @deleteSheet = $('#deleteSheetButton')
    @minimap = $('#minimapButton')
    @menubar = $('#menuBar')
    @menubar.on 'mousedown', (e) -> e.preventDefault()

    @newSheet.click ->
      if $(this).attr('rel') == 'text'
        TextSheet.create("text")

    @deleteSheet.click =>
      glob.activeSheet.socketRemove() if glob.activeSheet
      @deactivateDelete()

    @minimap.click -> minimap.toggle()

  activateDelete: ->
    @deleteSheet.css('background-image', 'url(/assets/images/delete_red.png)')
    
  deactivateDelete: ->
    @deleteSheet.css('background-image', 'url(/assets/images/delete_white.png)')
