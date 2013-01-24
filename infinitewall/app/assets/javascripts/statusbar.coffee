class window.Statusbar
  sB: null
  statuses: null
  statusID: 0

  constructor: ->
    @sB = $('#statusBar')
    @statuses = new Object()

  addStatus: (left, right = "") ->
    @statuses[@statusID] = new Status(@statusID++, left, right)

  removeStatus: (id, time = 0) ->
    timeoutID = setTimeout(
      =>
        @statuses[id].remove()
        @statuses[id] = null
      , time)
