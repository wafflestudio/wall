define ["jquery", "stage", "tree.jquery", "bootstrap", "angularbootstrap"], ($, Stage) ->
  "use strict"
  wallApp = angular.module("wallApp", ['ngRoute'])

  wallApp.controller 'WallManagement', ['$scope', '$http', '$compile', ($scope, $http, $compile) ->

      refresh = () ->
        $http.get("/tree").success (data, status) ->
          $('#tree').tree('loadData', data)
      
      $scope.deleteFolder = (id) ->
        $http.delete("/folder/" + id).success (data, status) ->
          refresh()

      $scope.createFolderAt = (id) ->
        console.log('create:' ,id)
        $('#folder-modal-create').modal('show')
        true

      $scope.init = () ->
        refresh()
        # folder test
        $('#tree').tree
          data: { label:"loading..", name:"loading" },
          autoOpen : true,
          dragAndDrop: true,
          onCreateLi: (node, $li) ->
            if node.type == 'folder'
              $li.addClass('item-folder')
              $li.find('.jqtree-element').prepend('<span class="fa fa-folder-o"></span> ').append($compile(
                '<div class="folder-selected-options pull-right" style="display:none">
                  <div class="btn-group">
                    <button type="button" class="btn btn-default btn-xs" ng-click="createFolderAt(' + node.id + ')">new folder</button>
                    <button type="button" class="btn btn-default btn-xs">new wall</button>' +
                    (if node.parent.parent then '<button type="button" class="btn btn-default btn-xs" ng-click="deleteFolder(' + node.id + ')">delete</button>' else '')
                  + '</div>
                </div>')($scope))
            else
              $li.addClass('item-wall')
            
              #$li.find('.jqtree-element').append('<a href="#node-'+ node.id +'" class="edit" data-node-id="'+ node.id +'">edit</a>')
              $li.find('.jqtree-element').prepend('<span class="fa fa-file-o"></span> ').append('
                <div class="folder-selected-options pull-right" style="display:none">
                  <div class="btn-group">
                    <button type="button" class="btn btn-default btn-xs">delete</button>
                  </div>
                </div>')
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
          console.log('new folder:', $('#folder-modal-create input').val())
          $('#folder-modal-create').modal('hide')

        true # prevent angularjs accessing dom element...

      $scope.newWall = {}

      $scope.createWall = () ->
        $http.post("/wall", $scope.newWall).success (data, status) ->
          refresh()
          $scope.newWall.title = ""
      
      $scope.deleteWall = (wallId) ->
        verified = confirm(Messages("wall.confirm_delete"))

        if verified
          $http.delete("/wall/#{wallId}").success (data, status) ->
            refresh()
    ]

  
  wallApp.controller 'Stage', ['$scope', '$http', ($scope, $http) ->
     
      refresh = () ->
        $http.get("/group/#{$scope.groupId}/user.json").success (data, status) ->
          $scope.users = data
        $http.get("/group/#{$scope.groupId}/wall.json").success (data, status) ->
          $scope.nonSharedWalls = data
        $http.get("/group/#{$scope.groupId}/wall/shared.json").success (data, status) ->
          $scope.sharedWalls = data

      $scope.init = (groupId) ->
        $scope.groupId = groupId
        refresh()
      
      $scope.newWall = {}
      $scope.newUser = {}

      $scope.addUser = () ->
        $http.post("/group/#{$scope.groupId}/user/with_email", $scope.newUser).success (data, status) ->
          refresh()
          $scope.newUser.email = ""

      $scope.removeUser = (userId) ->

        verified = confirm(Messages("group.confirm_removeUser"))
        if verified
          $http.delete("/group/#{$scope.groupId}/user/#{userId}/id").success (data, status) ->
            refresh()
            $scope.userId = ""


      $scope.createWall = () ->
        $http.post("/group/#{$scope.groupId}/wall", $scope.newWall).success (data, status) ->
          refresh()
          $scope.newWall.title = ""


      $scope.addWall = (wallId) ->
        $http.post("/group/#{$scope.groupId}/wall/#{wallId}").success (data, status) ->
          refresh()

      $scope.removeWall = (wallId) ->
        verified = confirm(Messages("group.confirm_unshareWall"))
        if verified
          $http.delete("/group/#{$scope.groupId}/wall/#{wallId}").success (data, status) ->
            refresh()
    ]
  # required for AMDs like requirejs:
  angular.bootstrap(document, ["wallApp"])
  wallApp
