define ["jquery", "tree/controller", "tree/createFolderModal", "angularbootstrap"], ($, Tree, Modal) ->
  "use strict"
  wallApp = angular.module("wallApp", ['ngRoute'])

  #tree = Tree.initController(wallApp, 'Tree')
  #modal = Modal.initDirective(wallApp, 'createFolderModal')
  wallApp.controller 'Stage', ['$scope', ($scope) ->
    #console.warn tree

    #modal.$on 'refresh', () ->
    #  tree.refresh()
    
    #tree.$on 'createFolder', (event, data) ->
    #  modal.show(data.id, data.name)

  ]

  # required for AMDs like requirejs:
  angular.bootstrap(document, ["wallApp"])
  wallApp
