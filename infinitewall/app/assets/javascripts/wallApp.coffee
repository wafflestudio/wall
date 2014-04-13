define ["jquery", "angularbootstrap"], ($) ->
  "use strict"
  wallApp = angular.module("wallApp", ['ngRoute'])

  wallApp.controller 'MenuCtrl', ['$scope', ($scope) ->
      $scope.isActive = (parentLocation) ->
        console.log parentLocation
        return window.location.pathname.substring(0, parentLocation.length) is parentLocation
    ]

  wallApp.controller 'Walls', ['$scope', '$http', ($scope, $http) ->
     
      refresh = () ->
        $http.get("/wall.json").success (data, status) ->
          $scope.nonSharedWalls = data
        $http.get("/wall/grouped.json").success (data, status) ->
          $scope.groupedWalls = data

      $scope.init = () ->
        refresh()
      
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

  
  wallApp.controller 'Groups', ['$scope', '$http', ($scope, $http) ->
     
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
  

