define ["jquery", "tree/view", "stage", "EventDispatcher", "tree.jquery", "bootstrap", "angularbootstrap"], ($, TreeView, Stage, EventDispatcher) ->
  "use strict"


  ###
    * methods:
    ** refresh()

    * events:

  ###
  class TreeController extends EventDispatcher
    @init: (app, name) ->

      tree = new TreeController

      app.controller name, ['$scope', '$http', '$compile', ($scope, $http, $compile) ->

        treeView = {} # initialize var

        refresh = () ->
          $http.get("/tree").success (data, status) ->
            treeView.loadData(data)

        $scope.queryNewFolder = (id) ->          
          tree.trigger('queryNewFolder', {at:id, name: ""})          

        $scope.queryDeleteFolder = (id) ->
          if confirm("Are you sure you want to delete this folder?") # TODO Messages("stage.confirm_delete_folder")
            $http.delete("/folder/" + id).success (data, status) ->
              refresh()

        $scope.queryDeleteWall = (wallId) ->
          if confirm(Messages("wall.confirm_delete"))
            $http.delete("/wall/#{wallId}").success (data, status) ->
              refresh()

        $scope.moveFolder = (movedId, targetId) ->
          $http.put("/folder/#{movedId}/moveTo/#{if targetId? then targetId else ""}").success (data, status) ->
            refresh()

        $scope.moveWall = (movedId, folderId) ->
          $http.put("/wall/#{movedId}/moveTo/#{if folderId? then folderId else ""}").success (data, status) ->
            refresh()

        $scope.init = (currentWallId) ->
          treeView = new TreeView('treeview', currentWallId, $scope, $compile)
          tree.refresh = () =>
            refresh()

          refresh()
          
          true # prevent angularjs accessing dom element...

        $scope.newWall = {}

        $scope.createWall = () ->
          $http.post("/wall", $scope.newWall).success (data, status) ->
            refresh()
            $scope.newWall.title = ""
        

      ]

      # return tree obj
      tree

    constructor: () ->
      super



