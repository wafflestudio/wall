define ["EventDispatcher"], (EventDispatcher) ->

  class Connection extends EventDispatcher

    constructor: () ->
      super()
