define ["jquery", "shortcut/keyboard"], ($, KeyboardJS) ->
  class Shortcut
    constructor: ->
      @list = {}

    onKeydown: (keysString, handler) ->
      if @list[keysString]
        console.log "clear"
        @list[keysString].clear()
      keyboard = KeyboardJS.on keysString, (e) => console.log('keypress'); handler()
      @list[keysString] = keyboard

    onKeyup: (keysString, handler) ->
      @list[keysString] = handler; console.log @list
      console.log "not supported"
