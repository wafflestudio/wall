define ["jquery", "tree.jquery"], ($) ->

  class TreeView
    constructor : (name, currentWallId, $scope, $compile) ->

      @treeDom = $('#'+name)

      $(@treeDom).tree
        data: { label:"loading..", name:"loading" },
        autoOpen : true,
        dragAndDrop: true,
        onCreateLi: (node, $li) =>
          if node.type == 'folder'
            $li.addClass('item-folder')
            $li.find('.jqtree-title').wrapInner('<b></b>')
            $li.find('.jqtree-element').prepend(@olderIcon).append($compile(@folder(node))($scope))
          else
            $li.addClass('item-wall')
          
            li = $li.find('.jqtree-element')
            li.prepend(@currentItem) if node.id == currentWallId
            li.prepend(@itemIcon).append($compile(@item(node))($scope))
        ,
        onCanMove : (node) ->
          node.parent.parent
        ,
        onCanMoveTo : (moved_node, target_node, position) ->
          if target_node.type == 'folder'
              position == 'inside' && moved_node.parent != target_node
          else
              false

      $(@treeDom).bind(
        'tree.move',
        (event) ->
            console.log('moved_node', event.move_info.moved_node.id)
            console.log('target_node', event.move_info.target_node.id)
            console.log('position', event.move_info.position)
            console.log('previous_parent', event.move_info.previous_parent.id)
            switch event.move_info.moved_node.type
              when 'folder'
                $scope.moveFolder(event.move_info.moved_node.id, event.move_info.target_node.id)
              when 'wall'
                $scope.moveWall(event.move_info.moved_node.id, event.move_info.target_node.id)
      )

      $(@treeDom).bind(
        'tree.select',
        (event) ->
          if event.node
            console.log('selected node element: ', event.node, event.node.element)
            $(event.node.element).children('.jqtree-element').find('.folder-selected-options').show(100)
          if event.deselected_node
            console.log('deselected node element: ', event.deselected_node)
            $(event.deselected_node.element).children('.jqtree-element').find('.folder-selected-options').hide()
          else if event.previous_node
            console.log('deselected node element: ', event.previous_node)
            $(event.previous_node.element).children('.jqtree-element').find('.folder-selected-options').hide()

      )

    folderIcon: ->
      '<span class="fa fa-folder-o"></span> '

    folder: (node) ->
      ("""<div class="folder-selected-options pull-right" style="display:none">
        <div class="btn-group">
          <button type="button" class="btn btn-default btn-xs" ng-click="queryNewFolder(#{(if node.parent.parent then "'#{node.id}'" else "")})">new folder</button>
          <button type="button" class="btn btn-default btn-xs">new wall</button>
          #{(if node.parent.parent then '<button type="button" class="btn btn-default btn-xs" ng-click="queryDeleteFolder(\'' + node.id + '\')">delete</button>' else '')}
        </div>
      </div>""")

    currentItem: ->
      '<span class="fa fa-eye"></span> '

    itemIcon: ->
      '<span class="fa fa-file-o"></span> '

    item: ->
      ('<div class="folder-selected-options pull-right" style="display:none">
          <div class="btn-group">
            <button type="button" class="btn btn-default btn-xs">delete</button>
          </div>
        </div>')

    loadData: (data) ->
      @treeDom.tree('loadData', data)
