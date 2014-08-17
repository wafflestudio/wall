define ["jquery", "tree/template", "stage", "tree.jquery", "bootstrap", "angularbootstrap"], ($, template, Stage) ->
  "use strict"

  class TreeController
    @initController: (app, name) ->

      app.directive name, ['$scope', '$http', '$compile', ($scope, $http, $compile) ->

        refresh = () ->
          $http.get("/tree").success (data, status) ->
            $('#tree').tree('loadData', data)
        
        $scope.deleteFolder = (id) ->
          if confirm("Are you sure you want to delete this folder?") # TODO Messages("stage.confirm_delete_folder")
            $http.delete("/folder/" + id).success (data, status) ->
              refresh()

        $scope.createFolder = (id) ->
          $scope.$emit('createFolder', {at: id, name: ""})
          true

        $scope.moveFolder = (movedId, targetId) ->
          $http.put("/folder/#{movedId}/moveTo/#{if targetId? then targetId else ""}").success (data, status) ->
            refresh()

        $scope.moveWall = (movedId, folderId) ->
          $http.put("/wall/#{movedId}/moveTo/#{if folderId? then folderId else ""}").success (data, status) ->
            refresh()

        $scope.init = (currentWallId) ->
          refresh()
          # folder test
          $('#tree').tree
            data: { label:"loading..", name:"loading" },
            autoOpen : true,
            dragAndDrop: true,
            onCreateLi: (node, $li) ->
              if node.type == 'folder'
                $li.addClass('item-folder')
                $li.find('.jqtree-title').wrapInner('<b></b>')
                $li.find('.jqtree-element').prepend(template.folderIcon).append($compile(template.folder(node))($scope))
              else
                $li.addClass('item-wall')
              
                li = $li.find('.jqtree-element')
                li.prepend(template.currentItem) if node.id == currentWallId
                li.prepend(template.itemIcon).append($compile(template.item(node))($scope))
            ,
            onCanMove : (node) ->
              node.parent.parent
            ,
            onCanMoveTo : (moved_node, target_node, position) ->
              if target_node.type == 'folder'
                  position == 'inside' && moved_node.parent != target_node
              else
                  false

          $('#tree').bind(
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

          $('#tree').bind(
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

          $('#folder-modal-create .modal-submit').on 'click', () ->
            $('#folder-modal-create').modal('hide')

          true # prevent angularjs accessing dom element...

        $scope.newWall = {}

        $scope.createWall = () ->
          $http.post("/wall", $scope.newWall).success (data, status) ->
            refresh()
            $scope.newWall.title = ""
        
        $scope.deleteWall = (wallId) ->
          if confirm(Messages("wall.confirm_delete"))
            $http.delete("/wall/#{wallId}").success (data, status) ->
              refresh()
      ]

