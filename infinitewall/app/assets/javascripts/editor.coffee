define ["jquery", "underscore", "text/util", "rangeutil"], ($, _, TextUtil, RangeUtil) ->


  $ () ->

    addLink = () ->
      console.log('add link called')

    # overlapping range
      # <div> | </div> <div> | </div>
      # cut/paste -> automatically adjusted by browser
      # check for validity/simplify

    # simplify elements
      # remove javascript and attributes events
      # <Br>
      # <li>, <ol><ul>
    
    # simplify styles
      # <p>
      # <a>
      # <h1> ~ <h6>
      # <section> ~ ... (html5)
      #

    $.fn.Editor = (options) ->
      this.each () ->
        textfield = $(this)
        $(textfield).attr('contenteditable', 'true')

        dispatchChangeEvent = () =>
          console.log('alteration detected')
          textfield.trigger('changeText')

        # capture copy & paste
        $(textfield).bind 'paste', () ->
          console.log('paste')
          dispatchChangeEvent()

        # activate focus event handlers:
        $(textfield).focusin (e)=>
          console.log("focus text field")
          intervalId = setInterval(dispatchChangeEvent, 8000)
          # deactivate when focused out
          deactivate = ()=>
            dispatchChangeEvent() # check change for the last time
            clearInterval(intervalId)
            textfield.off 'focusout', deactivate
            $(textfield).get(0).normalize()

          $(textfield).on 'focusout', deactivate
          e.preventDefault()

        $(textfield).on 'keydown', (e) =>          
          if e.keyCode == 27
            e.preventDefault()
            false

        # activate key event handlers
        $(textfield).on 'keypress', (e)=>
          console.log('keypress', e.keyCode, e.which)
          dispatchChangeEvent()

        # check for any update by the browser
        $(
          () =>
            setTimeout dispatchChangeEvent
        ,
        200)

        console.log("initialized Editor plugin")

      this


        
