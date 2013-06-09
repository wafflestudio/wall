define ["./folder_node", "./folder_item", "jquery"], (Node, Item, $) ->
  class Folder extends Node
    constructor: (parent, nodeData, level)->
      super(parent, nodeData, level)
      #$.extend(this, new this.$super(parent, nodeData));

      template = "<div class='folder'></div>"
      @element = $(template)
      if level == 0
        @element.addClass('folder-root')
      
      containerTemplate = "<div class='folder-items'></div>"
      childContainer = $(containerTemplate)

      @element.append(childContainer)

      children = []

      if nodeData.children
        for childNodeData in  nodeData.children
          if childNodeData.type == 'folder'
            child = new Folder(this, childNodeData, level + 1)
          else
            child = new Item(this, childNodeData, level + 1)

          children.push(child)

          # append child
          childContainer.append(child.element);
          # listen for events
          child.on 'focus', (child) =>
            @trigger('childFocus', child)

          child.on 'selected', (child) =>
            @trigger('childSelected', child)
          
          do (child) =>
            child.on 'childFocus', (child) =>
              @trigger('childFocus', child)

            child.on 'childSelected', (child) =>
              @trigger('childSelected', child)

          
          child.on 'unfocus', () =>
            @trigger('childUnfocus') 

      @childContainer = childContainer
      @type = "folder"
      @children = children
      @element.prepend('<p class="node-drag-helper"><i class="icon-folder-open"></i> ' + @name + 
        '<a class="node-delete-btn" href="javascript:void()"><i class="icon-remove-sign"></i></a></p>')

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

      isAncestor = (a, b) ->
        # console.log('isAncestor')
        found = false
        $(b).parents('.folder').each (i, el)->
          if $(a).data('id') == $(el).data('id')
            found = true
          # console.log('comparing', 'draggable:', $(a).data('id'), 'droppable:', $(b).data('id'), 'parent of dropppable:', $(el).data('id'))
        found

      console.log(nodeData.id)
      p.droppable(
        accept: (draggable) =>
          # console.log("accept test draggable:", $(draggable).data('id'), "droppable:", p.data('id'), $(draggable).data('parentId'))
          return $(draggable).hasClass('node-drag-helper') and !isAncestor(draggable, p) and 
            $(draggable).data('parentId') != p.data('id')
        over: (e, ui) =>
          @element.addClass('drophover')
        out: (e, ui) =>
          @element.removeClass('drophover')
        deactivate: (e, ui) =>
          @element.removeClass('drophover')

        greedy: true
      )

      # initialize hover
      p.mouseover (e) ->
        $(this).addClass('hover')
        $(this).find('.node-delete-btn').show()

      p.mouseout (e) ->
        $(this).removeClass('hover')
        $(this).find('.node-delete-btn').hide()

      # initialize focus click
      $(@element).on 'click', (e) =>
        @trigger('focus', this)
        e.stopPropagation()
    

   

