define ["jquery", "underscore"], ($, _) ->

  class Editor

    constructor: (el) ->
      # add contenteditable attr
      $(el).attr('contenteditable', 'true')

      # capture keypress
      $(el).keypress () ->
        console.log('keypress')

      # capture copy & paste
      $(el).bind 'paste', () -> 
        console.log('paste')

      # add timer
      # precheck before sending
      # throttled

    amend: ()->
      
      # overlapping range
        # <div> | </div> <div> | </div>
        # cut/paste -> automatically adjusted by browser
        # check for validity/simplify

      # simplify elements
        # remove javascript and events
        # <Br>
        # <li>, <ol><ul>
        # <p>
        # <a>
        # <h1> ~ <h6>
        # <section> ~ ... (html5)
        #

    