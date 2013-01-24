class window.Status
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
