define ["jquery", "stage", "EventDispatcher", "tree.jquery", "bootstrap", "angularbootstrap"], ($, Stage, EventDispatcher) ->

  ###
    * methods:
    ** appendTo(jqueryselector) 
    ** element -> jquery element representing modal
  ###
  class ModalView
    constructor: ->

    appendTo:(jqStr) ->
      $(jqStr).append(@template)

    element: ->
      $('#folder-modal-create')

    template: ->
      """
<div id="folder-modal-create" class="modal fade bs-example-modal-sm" tabindex="-1" role="dialog" aria-labelledby="mySmallModalLabel" aria-hidden="true" createFolderModal>
<div class="modal-dialog modal-sm">
  <div class="modal-content">
    <form ng-submit="createFolder()">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        <h4 class="modal-title" id="myModalLabel">Create Folder</h4>
      </div>
      <div class="modal-body">
        <div class="form-group">
            <label for="folderNameCreate">Name</label>
            <input type="text" class="form-control" id="folderNameCreate" placeholder="A suitable name for your folder" ng-model="name">
        </form>
      </div>
    </form>
    <div class="modal-footer">
      <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
      <button type="submit" class="btn btn-primary modal-submit">Save changes</button>
    </div>
  </div>
</div>
</div>
      """


  ###
    * methods:
    ** open (folderAt, name)
    ** close ()

    * events:
    ** open (at, name)
    ** close (at, name)
    ** submit (at, name)

    * angular binds
    ** init(currentWallId)
    ** createFolder()

  ###
  class Modal extends EventDispatcher

    @init: (app, name, modalElementId) ->

      modal = new Modal

      app.controller name, ['$scope', '$http', ($scope, $http) ->
        element = {}        

        $scope.init = (currentWallId) =>
          element = $('#folder-modal-create')
          # FIXME: element created on-the-fly
          # element = new ModalView
          # @element.appendTo('body')
          true # prevent angularjs accessing dom element...

        $scope.createFolder = () ->  
          event = {at:$scope.folderAt, name:$scope.name}
          $http.post("/folder/#{if $scope.folderAt? then $scope.folderAt else ""}", {name : $scope.name}).success (data, status) ->
            $(element).modal('hide')
            modal.trigger('submit', event)
        
        modal.open = (folderAt, name) ->
          $scope.folderAt = folderAt
          $scope.name = name
          $(element).modal('show')
          modal.trigger('open', {at:folderAt, name:name})

        modal.close = () ->
          $(element).modal('hide')
          modal.trigger('close', {at:$scope.folderAt, name:$scope.name})
      ]
      
      # return created modal obj
      modal

    constructor:() ->
      super()

    

