define ["./operation"], (Operation) ->
  class TextUtil

    @spliceString : (str, offset, remove, add) ->
      #console.log("*", str.substr(0,offset),"*", (if add? then add else ""),"*",str.substr(Math.max(0,offset+remove)))
      str.substr(0,offset) + (if add? then add else "") + str.substr(Math.max(0, offset+remove))

    @createUndo : (oldStr, newStr, operation) ->
      remove = operation.content.length
      p1 = Math.min(Math.max(0, operation.from), oldStr.length)
      p2 = Math.min(Math.max(0, operation.from + operation.length), oldStr.length)
      p2_ = Math.min(Math.max(0, operation.from + remove), newStr.length)
      content = oldStr.substring(p1, p2)
      oldStrByCalc = newStr.substring(0, p1) + content + newStr.substring(p2_, newStr.length)

      undoOperation = new Operation(p1, remove, content)
      if(oldStr !=  oldStrByCalc)
        console.error(oldStr)
        console.error(oldStrByCalc)
        console.error(undoOperation)
        throw "assertion oldStr == oldStrByCalc failed"
      undoOperation


    @detectOperation : (old, current, range) ->
      # add
      # delete
      # replace

      if !range?
        range = [0, current.length -1]
      
      range[0] = if range[0] <= current.length then range[0] else current.length-1
      range[1] = if range[1] <= current.length then range[1] else current.length-1
      range[0] = if range[0] > 0 then range[0] else 0
      range[1] = if range[1] > 0 then range[1] else 0

      heuristic = ()->
        # there is no range. meaing we need heuristics to detect change
        cursor = range[1]
        
        ZstartAtCurrent = current.length
        ZstartAtOld = old.length
        
        #make sure cursor <= Zstart

        i = current.length - 1
        j = old.length - 1
        while i >= cursor and i >= 0 and j >= 0
          if current.charCodeAt(i) == old.charCodeAt(j)
            ZstartAtCurrent = i
            ZstartAtOld = j
          else
            break
          i--
          j--

        # make sure Xend < cursor
        Xend = -1

        i = 0
        while i < old.length and i < current.length and i < ZstartAtCurrent and i < ZstartAtOld
          if current.charCodeAt(i) == old.charCodeAt(i)
            Xend = i
          else
            break
          i++

        if TextUtil.spliceString(old, Xend+1, ZstartAtOld-Xend-1, current.substr(Xend+1, ZstartAtCurrent-Xend-1)) != current
          console.log('old:', old.length, old)
          console.log('current:', current.length, current)
          console.log("r:", range)
          console.log("Xend:", Xend, ",Zstart(old):", ZstartAtOld, ",Zstart(cur):", ZstartAtCurrent, "added:", current.substr(Xend+1, ZstartAtCurrent-Xend-1))
          console.warn TextUtil.spliceString(old, Xend+1, ZstartAtOld-Xend-1, current.substr(Xend+1, ZstartAtCurrent-Xend-1)), current
          throw "operation error"

        [new Operation(Xend+1, ZstartAtOld-Xend-1, current.substr(Xend+1,ZstartAtCurrent-Xend-1), [cursor,cursor]) , old.substr(Xend+1, ZstartAtOld-Xend-1)]


      if range[1] == range[0]
        heuristic()
      else
        # there is range, meaning the person did undo/redo. clearly the difference is in the range
        # case 1: replaced selection & undo
        # case 2: deleted selection & undo
        if range[0] > range[1]
          rangeEnd = range[0]
          rangeBegin = range[1]
        else
          rangeEnd = range[1]
          rangeBegin = range[0]

        diffBegin = rangeBegin
        diffEnd = old.length - (current.length - rangeEnd)

        if current.substr(0, diffBegin) != old.substr(0,diffBegin) or current.substr(rangeEnd) != old.substr(diffEnd)
          console.error('something is wrong with the text change. Falling back to heuristics')
          heuristic()
        else
          [new Operation(diffBegin, diffEnd-diffBegin, current.substr(diffBegin, rangeEnd - rangeBegin), range), old.substr(diffBegin, diffEnd-diffBegin)]


