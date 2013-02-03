
class Operation
    constructor: (@from, @length, @content) ->
 
class CharWithState
    constructor: (@c, @insertedBy = {}, @deletedBy = {}) ->

        
    setDeletedBy: (branch) ->
        @deletedBy[branch] = true
    setInsertedBy: (branch) ->
        @insertedBy[branch] = true
    
    
class StringWithState
    constructor:(str)->
        i = 0
        @list = []
        while i < str.length
            @list.push(new CharWithState(str.charAt(i)))
            i++

    apply:(op, branch) ->
        i = 0
        iBranch = 0
        insertPos = 0
        alteredFrom = 0
        numDeleted = 0
        iAtIBranch = 0

        @list = for cs in @list
            if !cs.deletedBy[branch] && (Object.keys(cs.insertedBy).length == 0 || cs.insertedBy[branch])
                if iBranch >= op.from && iBranch < op.from + op.length
                    if Object.keys(cs.deletedBy).length == 0
                        numDeleted++
                    cs.deletedBy[branch] = true
                    insertPos = i
                else if iBranch == op.from + op.length
                    insertPos = i
                iBranch++
                iAtIBranch = i+1
            i++
            cs

        if iBranch <= op.from
          insertPos = iAtIBranch

        inserted = for c in op.content
            insertedBy = {}
            insertedBy[branch] = true
            new CharWithState(c, insertedBy)
        
        i = 0
        for cs in @list
            if i < insertPos
                if Object.keys(cs.deletedBy).length == 0
                    alteredFrom++
            i++

        @list = @list.slice(0, insertPos).concat(inserted).concat(@list.slice(insertPos))
        new Operation(alteredFrom, numDeleted, op.content)

    clone:() ->
        ss = new StringWithState("")
        ss.list = for cs in @list
            insertedBy = {}
            deletedBy = {}
            for k,v of cs.insertedBy
                insertedBy[k] = v
            for k,v of cs.deletedBy
                deletedBy[k] = v

            new CharWithState(cs.c, insertedBy, deletedBy)
        ss


    text:() ->
        text = ""
        i = 0
        while i < @list.length
            cs = @list[i]
            if Object.keys(cs.deletedBy).length == 0
                text += cs.c
            i++
        text

    html:() ->
        html = ""
        i = 0
        while i < @list.length
            cs = @list[i]
            classes = []
            if Object.keys(cs.deletedBy).length > 0
                classes.push('deleted')
            if Object.keys(cs.insertedBy).length > 0
                classes.push('inserted')
            branches = {}
            for b,v of cs.deletedBy
              branches[b] = true
            for b,v of cs.insertedBy
              branches[b] = true
            for b,v of branches
              classes.push("b#{b}")
            # if cs.deletedBy[A] || cs.deletedByA
            #     classes.push('A')
            # if cs.insertedByB || cs.deletedByB
            #     classes.push('B')

            if classes.length > 0
                html = html + "<span class='#{classes.join(' ')}'>#{cs.c}</span>"
            else
                html = html + cs.c

            i++

        html
                   

spliceString = (str, offset, remove, add) ->
  #console.log("*", str.substr(0,offset),"*", (if add? then add else ""),"*",str.substr(Math.max(0,offset+remove)))
  str.substr(0,offset) + (if add? then add else "") + str.substr(Math.max(0, offset+remove))


detectOperation = (old, current, range) ->

  # add
  # delete
  # replace
  
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

    if spliceString(old, Xend+1, ZstartAtOld-Xend-1, current.substr(Xend+1, ZstartAtCurrent-Xend-1)) != current
      console.log('old:', old.length, old)
      console.log('current:', current.length, current)
      console.log("r:", range)
      console.log("Xend:", Xend, ",Zstart(old):", ZstartAtOld, ",Zstart(cur):", ZstartAtCurrent, "added:", current.substr(Xend+1, ZstartAtCurrent-Xend-1))
      console.warn spliceString(old, Xend+1, ZstartAtOld-Xend-1, current.substr(Xend+1, ZstartAtCurrent-Xend-1)), current
      throw "operation error"

    {from: Xend+1, length: ZstartAtOld-Xend-1, content: current.substr(Xend+1,ZstartAtCurrent-Xend-1), range: [cursor,cursor]}


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
      {from: diffBegin, length: diffEnd-diffBegin, content: current.substr(diffBegin, rangeEnd - rangeBegin), range: range}

#export modules
modules.detectOperation = detectOperation
modules.spliceString = spliceString
modules.Operation = Operation
modules.CharWithState = CharWithState
modules.StringWithState = StringWithState
