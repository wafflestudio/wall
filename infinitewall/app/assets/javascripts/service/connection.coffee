define ["common/EventDispatcher"], (EventDispatcher) ->

  class Connection extends EventDispatcher

    constructor: () ->
      super()
