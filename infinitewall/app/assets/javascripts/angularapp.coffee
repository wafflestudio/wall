define ["jquery", "angular"], ($, Angular) ->
  app = angular.module("WallApp", [])
  
  app.controller 'MenuCtrl', ['$scope', ($scope) ->
      $scope.isActive = (parentLocation) ->
        console.log parentLocation
        return window.location.pathname.substring(0, parentLocation.length) is parentLocation
    ]

  $(document).on 'ready page:load', ->
    angular.bootstrap document, ['WallApp']
