define ["jquery"], ($) ->
  class History
    undoStack: []
    redoStack: []

    constructor: () ->
      @undoStack = []
      @redoStack = []

    sendUndoAction: (targetAction, histAction) ->
      @sendAction(targetAction)
      wallSocket.sendUndoAction(targetAction, histAction)

    sendRedoAction: (targetAction, histAction) ->
      @sendAction(targetAction)
      wallSocket.sendRedoAction(targetAction, histAction)

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
          @sendUndoAction(target.from, target.to)

    redo: () ->
      if @redoStack.length == 0
        console.error("RedoStack is empty")
      else
        target = @redoStack.pop()
        timestamp = target.to.timestamp

        # collect same timestamp action
        actionStack = [target]
        while @redoStack.length != 0
          target = @redoStack.pop()
          if target.to.timestamp == timestamp
            actionStack.push(target)
          else
            @redoStack.push(target)
            break

        while actionStack.length != 0
          target = actionStack.pop()
          @sendRedoAction(target.from, target.to)

    updateStack: (detail, histStack) ->
      switch detail.action
        when "create"
          poppedStack = []
          while histStack.length != 0
            target = histStack.pop()
            if target.to.timestamp == detail.timestamp - 1 #FIXME
              target.from.params = {sheetId: detail.sheetId}
              $.extend(target.to.params, {sheetId: detail.sheetId})
              poppedStack.push(target)
              break
            else
              poppedStack.push(target)
          histStack = histStack.concat(poppedStack.reverse())
        else console.error "Not require to update", detail
      histStack

    update: (detail) ->
      @undoStack = @updateStack(detail, @undoStack)
      @redoStack = @updateStack(detail, @redoStack)

    push: (action) ->
      @undoStack.push(action)
      @redoStack = []

    repush: (action) ->
      @redoStack.push(action)

    sendAction: (detail) ->
      sheet = stage.sheets[detail.params.sheetId]
      isMine = false
      switch detail.action
        #when "alterText" then sheet.alterText(detail.params, isMine, detail.htimestamp)
        when "create" then console.info("Nothing to do, just wait")#stage.createSheet(detail.sheetId, detail.params, detail.timestamp)
        when "move" then sheet.move(detail.params) unless isMine
        when "resize" then sheet.resize(detail.params) unless isMine
        when "remove" then sheet.remove(detail.params)
        #when "setTitle" then sheet.setTitle(detail.params) unless isMine
        when "setLink" then console.info("Nothing to do, just wait")#sheet.setLink(detail.params)
        when "removeLink" then console.info("Nothing to do, just wait")#sheet.removeLink(detail.params)
        else console.error("Not supported action", detail)
