define ["jquery", "tree/template", "stage", "tree.jquery", "bootstrap", "angularbootstrap"], ($, template, Stage) ->

  class Modal
    @initDirective: (app, name) ->

      app.directive name, ['$http', ($http) ->
        {
          link: (scope, element, attrs) ->
            scope.show = (folderAt, name) ->
              scope.folderAt = folderAt
              scope.name = name
              $(element).modal('show')

            scope.hide = () ->
              $(element).modal('hide')

            scope.createFolder = () ->
              $http.post("/folder/#{if scope.newFolderAt? then scope.newFolderAt else ""}", {name : scope.name}).success (data, status) ->
                scope.$emit('refresh')

        }
      ]
