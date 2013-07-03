define ["jquery"], ($) ->
  class History
    stack: []
    unstack: []
    tmpAction: {}

    constructor: () ->
      @stack = []
      @unstack = []
      @tmpAction = {}

    undo: () ->
      if @stack.length == 0
        console.error("Stack is empty")
      else
        target = @stack.pop()
        @sendAction(target)
        @repush(target)

    redo: () ->
      if @unstack.length == 0
        console.error("Stack is empty")
      else
        target = @unstack.pop()
        @sendAction(target)
        @push(target)

    push: (action) ->
      console.info(action)
      @stack.push(action)

    repush: (action) ->
      console.info(action)
      @unstack.push(action)

    sendAction: (action) ->
      sheet = stage.sheets[action.params.sheetId]
      isMine = false
      switch action.action
        when "alterText" then sheet.alterText(action.params, isMine, timestamp)
        when "create" then stage.createSheet(action.sheetId, action.params, timestamp)
        when "move" then sheet.move(action.params) unless isMine
        when "resize" then sheet.resize(action.params) unless isMine
        when "remove" then sheet.remove(action.params)
        when "setTitle" then sheet.setTitle(action.params) unless isMine
        when "setLink" then sheet.setLink(action.params)
        when "removeLink" then sheet.removeLink(action.params)
