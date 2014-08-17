define ["jquery"], ($) ->
  class TreeTemplate
    @folderIcon: () ->
      '<span class="fa fa-folder-o"></span> '

    @folder: (node) ->
      ("""<div class="folder-selected-options pull-right" style="display:none">
        <div class="btn-group">
          <button type="button" class="btn btn-default btn-xs" ng-click="createFolder(#{(if node.parent.parent then "'#{node.id}'" else "")})">new folder</button>
          <button type="button" class="btn btn-default btn-xs">new wall</button>
          #{(if node.parent.parent then '<button type="button" class="btn btn-default btn-xs" ng-click="deleteFolder(\'' + node.id + '\')">delete</button>' else '')}
        </div>
      </div>""")

    @currentItem: () ->
      '<span class="fa fa-eye"></span> '

    @itemIcon: () ->
      '<span class="fa fa-file-o"></span> '

    @item: () ->
      ('<div class="folder-selected-options pull-right" style="display:none">
          <div class="btn-group">
            <button type="button" class="btn btn-default btn-xs">delete</button>
          </div>
        </div>')
