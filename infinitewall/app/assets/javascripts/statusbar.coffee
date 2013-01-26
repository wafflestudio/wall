class Status
  element: null
  id: null

  constructor: (id, left, right = "") ->
    @id = id
    @element = $("
    <div class = 'statusContainer'>
      <div class = 'statusText'>#{left}</div>
      <div class = 'statusTextRight'>#{right}</div>
    </div>").appendTo('#statusBar')

  changeLeftText: (left) -> @element.children('.statusText').text(left)
  changeRightText: (right) -> @element.children('.statusTextRight').text(right)

  changeText: (left, right) ->
    @changeLeftText(left)
    @changeRightText(right)

  remove: ->
    @element.transition { opacity: 0 }, => @element.remove()

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
        delete @statuses[id]
      , time)
