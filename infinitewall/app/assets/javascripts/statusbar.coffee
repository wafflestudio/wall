class Status
  element: null
  id: null

  constructor: (id, left, right = "") ->
    @id = id
    @element = $("<div class = 'statusContainer'>
      <div class = 'statusText'>#{left}</div>
      <div class = 'statusTextRight'>#{right}</div>
    </div>").appendTo('#statusBar')

    @element.children(".statusText").width("225px") if right

  changeLeftText: (left) -> @element.children('.statusText').text(left)
  changeRightText: (right) ->
    @element.children('.statusTextRight').text(right)
    if right
      @element.children('.statusText').width("225px")
    else
      @element.children('.statusText').width("275px") # 빈 스트링이 들어오면 길게 함

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

  instantStatus: (left, right = "", time = 1000) ->
    if typeof right is "number"
      time = right
      right = ""

    @addStatus(left, right)
    @removeStatus(@statusID - 1, time)
