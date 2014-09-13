define ["jquery", "tree/controller", "tree/createFolderModal", "angularbootstrap"], ($, Tree, Modal) ->
  "use strict"
  wallApp = angular.module("wallApp", ['ngRoute'])

  # need Tree DOM template
  # 
  tree = Tree.init(wallApp, 'Tree')
  modal = Modal.init(wallApp, 'createFolderModal')
  wallApp.controller 'Stage', ['$scope', ($scope) ->
    #console.warn Tree

    modal.on 'submit', (data) ->
      tree.refresh()

    tree.on 'queryNewFolder',  (data) ->
      console.warn(data)
      modal.open(data.at, data.name)
  ]

  # required for AMDs like requirejs:
  angular.bootstrap(document, ["wallApp"])
  wallApp
