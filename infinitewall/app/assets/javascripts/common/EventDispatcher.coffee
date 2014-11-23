define [], () ->
  class EventDispatcher

    constructor:() ->
      eventHandlers = {}

      @once = (evtName, handler) ->
        eventHandlers[evtName] = eventHandlers[evtName] || []
        eventHandlers[evtName].push([handler, true])

      @on = (evtName, handler) ->
        eventHandlers[evtName] = eventHandlers[evtName] || []
        eventHandlers[evtName].push([handler, false])

      @off = (evtName, handler) ->
        eventHandlers[evtName] = eventHandlers[evtName] || []
        i = 0
        while i < eventHandlers[evtName].length
          target = eventHandlers[evtName][i][0]
          if handler == target
            eventHandlers[evtName].splice(i,1)
          else
            i = i + 1

      @trigger = (evtName) ->
        args = []
        i = 1
        while i < arguments.length
          args.push(arguments[i])
          i = i + 1
        
        handlers = eventHandlers[evtName]

        if !handlers
          return

        triggeredOnce = []
        # result is for following dom event convention for propagation control
        result = true

        for handler in handlers
          inter_result = handler[0].apply(this, args) || false
          result = inter_result && result
          if handler[1]
            triggeredOnce.push(handler[0])

        for handler in triggeredOnce
          @off(evtName, handler)

        result
        
      @clear = (evtName) ->
        if evtName
          eventHandlers[evtName] = []
        else
          eventHandlers = {}


  test = () ->
    assert = (expr,msg) ->
      if !expr
        alert 'failed assertion: ' + msg
    
    dummy = new EventDispatcher
    subject = 0
    args = []
    a = (ar) ->
      subject += 1
      args.push(ar)

    aa = (ar) ->
      subject *= 2
      args.push(ar)

    dummy.on("a",  a)
    dummy.trigger("a", 1)
    dummy.trigger("a", 2)
    assert(subject == 2, "subject == 2: " + subject)
    #assert(args == [1,2])
    dummy.on("a", aa )
    dummy.off("a", a)
    dummy.trigger("a")
    assert(subject == 4)
    dummy.clear()
    dummy.trigger("a")
    assert(subject == 4)

  test()

  EventDispatcher
