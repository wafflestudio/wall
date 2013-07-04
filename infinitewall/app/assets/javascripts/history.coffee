define ["jquery"], ($) ->
  class History
    undoStack: []
    redoStack: []
    tmpAction: {}

    constructor: () ->
      @undoStack = []
      @redoStack = []
      @tmpAction = {}

    undo: () ->
      if @undoStack.length == 0
        console.error("UndoStack is empty")
      else
        target = @undoStack.pop()
        timestamp = target.to.timestamp

        # collect same timestamp action
        actionStack = [target]
        while @undoStack.length != 0
          target = @undoStack.pop()
          if target.to.timestamp == timestamp
            actionStack.push(target)
          else
            @undoStack.push(target)
            break

        while actionStack.length != 0
          target = actionStack.pop()
          @sendAction(target.from)
          @repush(target)

    redo: () ->
      if @redoStack.length == 0
        console.error("RedoStack is empty")
      else
        target = @redoStack.pop()
        redoStack = @redoStack
        @sendAction(target.to)
        @push(target)
        @redoStack = redoStack

    update: (detail) ->
      switch detail.action
        when "create"
          poppedStack = []
          while @undoStack.length != 0
            target = @undoStack.pop()
            if target.to.timestamp == detail.timestamp - 1 #FIXME
              target.from.params = {sheetId: detail.sheetId}
              $.extend(target.to.params, {sheetId: detail.sheetId})
              poppedStack.push(target)
              break
            else
              poppedStack.push(target)
          @undoStack = @undoStack.concat(poppedStack.reverse())
        else console.error "Not require to update", detail

    push: (action) ->
      @undoStack.push(action)
      @redoStack = []

    repush: (action) ->
      @redoStack.push(action)

    sendAction: (detail) ->
      sheet = stage.sheets[detail.params.sheetId]
      isMine = false
      switch detail.action
        when "alterText" then sheet.alterText(detail.params, isMine, detailtimestamp)
        when "create" then stage.createSheet(detail.sheetId, detail.params, detail.timestamp)
        when "move" then sheet.move(detail.params) unless isMine
        when "resize" then sheet.resize(detail.params) unless isMine
        when "remove" then sheet.remove(detail.params)
        when "setTitle" then sheet.setTitle(detail.params) unless isMine
        when "setLink" then sheet.setLink(detail.params)
        when "removeLink" then sheet.removeLink(detail.params)
        else console.error("Not supported action", detail)
