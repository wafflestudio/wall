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
    @activated = true
    @listen()

  deactivate: () ->
    @activated = false
    
  # listen: create listener ajax stream via iframe
  listen:() ->
    @iframeId = window.CometSocket.iframeId
    window.CometSocket.iframeId += 1
    @iframe = $("<iframe id='#cometSocket#{@iframeId}' src='#{@listenurl}'></iframe>").appendTo('body')
    @iframe.get(0).contentWindow.triggerOnReceive = (msg) =>
      @onReceive(msg)

    # # make sure to reconnect when iframe is done loading
    # @iframe.load( =>
    #   console.log('iframe load done')
    #   @iframe.remove() # garbage collect
    #   _.delay(_.bind(@listen, this), 5000)
    # )

    abortRetry = () =>
      @iframe.remove()
      _.delay(_.bind(@listen, this), 15000) if @activated

    _.delay(_.bind(abortRetry, this), 2000)

  send: (msg)->
    
    buffered = []
    for msg in @pending
      buffered.push(msg)

    $.ajax(@speakurl, {type:'POST', contents: {actions:buffered}}).done( =>
      console.info('send action via http successful')
    ).fail( =>
      console.warn('send action via http failed')
    ).always( =>
    
    )

  onReceive: (msg)->
    console.info(@scope, msg)
    @trigger('receive', msg)

