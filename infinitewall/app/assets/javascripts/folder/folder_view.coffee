define ["EventDispatcher", "jquery", "./folder"], (EventDispatcher, $, Folder) ->

  class FolderView extends EventDispatcher
    # sample nodeData
    # {type: "folder", id:1, name:"study", children:[{type:"folder", id:2, name:"0201", children:[]}]}
    constructor: (nodeData)->
      super()
      @selectedNodes = []
      rootData = {type: "folder", id: -1, name: "/", children:nodeData}
      @container = $('<div class="folder-view"></div>')
      @root = new Folder(null, rootData, 0)
      @root.on 'selected', (target) =>
        @selected = target

      @root.on 'childSelected', (target) =>
        @selected = target
      
      @bottombar = $('<div class="folder-bottombar">
        <div>
        <form method="POST" action="/wall/create" class="form-inline">
          <input name="title" type="text" placeholder="New Wall"> <button class="btn">Create</button/>
        </form></div>
        </div>')
      

      @container.append(@root.element)
      @container.append(@bottombar)
      
    appendTo: (jq) =>
        $(jq).append(@container)
        
    

