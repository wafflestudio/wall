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
      @unstack = []

    repush: (action) ->
      console.info(action)
      @unstack.push(action)

    sendAction: (detail) ->
      sheet = stage.sheets[detail.params.sheetId]
      isMine = false
      switch detail.action
        when "alterText" then sheet.alterText(detail.params, isMine, timestamp)
        when "create" then stage.createSheet(detail.sheetId, detail.params, timestamp)
        when "move" then sheet.move(detail.params) unless isMine
        when "resize" then sheet.resize(detail.params) unless isMine
        when "remove" then sheet.remove(detail.params)
        when "setTitle" then sheet.setTitle(detail.params) unless isMine
        when "setLink" then sheet.setLink(detail.params)
        when "removeLink" then sheet.removeLink(detail.params)
        else console.error("Not supported action", detail)
