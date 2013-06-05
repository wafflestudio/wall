# required for extending:
# @timestamp
# @url
# @scope

# states: CONNECTED <=> TRYING

class window.CometSocket extends EventDispatcher
  @iframeId = 1

  constructor: (speakurl, listenurl, scope = "COMET", @timestamp)->
    super()
    @speakurl = speakurl
    @listenurl = listenurl 
    @scope = "[#{scope}]"
    @activated = false
    
  activate: () ->
    @listen() if not @activated
    @activated = true

  deactivate: () ->
    @activated = false

  url: () ->
    @listenurl + "&timestamp=#{@timestamp}"
    
  # listen: create listener ajax stream via iframe
  listen:() ->
    @iframeId = window.CometSocket.iframeId
    window.CometSocket.iframeId += 1
    iframe = $("<iframe id='#cometSocket#{@iframeId}' src='#{@url()}'></iframe>").appendTo('body')
    iframe.get(0).contentWindow.triggerOnReceive = (msg) =>
      @onReceive(msg)

    # # make sure to reconnect when iframe is done loading
    # @iframe.load( =>
    #   console.log('iframe load done')
    #   @iframe.remove() # garbage collect
    #   _.delay(_.bind(@listen, this), 5000)
    # )

    abortRetry = () =>
      iframe.attr('src', 'about:blank')
      iframe.remove()
      _.delay(_.bind(@listen, this), 15000) if @activated

    _.delay(_.bind(abortRetry, this), 2000)

  send: (msg)->
    
    $.ajax(@speakurl, {type:'POST', data: JSON.stringify(msg), contentType:"text/plain" } ).done( =>
      console.debug('send action via http successful')
    ).fail( =>
      console.warn('send action via http failed with error')
    ).always( =>
    
    )

  onReceive: (msg)->
    #console.info(@scope, msg)
    @trigger('receive', msg)

