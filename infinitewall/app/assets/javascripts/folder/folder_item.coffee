define ["./folder_node", "jquery", "jquery-ui"], (Node, $) ->
  class Item extends Node
    constructor: (parent, nodeData, level)->
      super(parent, nodeData, level)
      
      template = "<div class='folder-item'></div>"
      element = $(template)
      
      element.append('<p class="node-drag-helper"><i class="icon-file"></i> ' + @name +
        '<a class="node-delete-btn" href="javascript:void()"><i class="icon-remove-sign"></i></a></p>')

      @element = element
      @type = "item"

      p = @element.children('p')

      # initialize drag/drop
      @element.data('id', nodeData.id)
      @element.data('level', level)
      p.data('id', nodeData.id)
      p.data('level', level)
      p.children('.node-delete-btn').hide()


      if parent?
        @element.data('parentId', parent.id)
        p.data('parentId', parent.id)

      p.draggable({revert:'invalid', helper:'clone'})

      p.mouseover (e) ->
        $(this).addClass('hover')
        $(p).children('.node-delete-btn').show()

      p.mouseout (e) ->
        $(this).removeClass('hover')
        $(p).children('.node-delete-btn').hide()

      $(@element).on 'click', (e) =>
        @trigger('focus', this)
        e.stopPropagation()
   
