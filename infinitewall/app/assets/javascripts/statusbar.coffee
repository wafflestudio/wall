class window.Statusbar
  sB: null
  statuses: null
  statusID: 0

  constructor: ->
    @sB = $('#statusBar')
    @statuses = new Object()

  statusTemplate: (left, right = "") -> $("
    <div class = 'statusContainer'>
      <div class = 'statusText'>#{left}</div>
      <div class = 'statusTextRight'>#{right}</div>
    </div>")

  addStatus: (left, right = "") ->
    @statuses[@statusID++] = @statusTemplate(left, right).appendTo(@sB)
