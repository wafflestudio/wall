
var FolderView = (function() {

// sample nodeData
// {type: "folder", name:"study", children:[{type:"folder", name:"0201", children:[]}]}

function Node(parent, nodeData) {
	$.extend(this, new this.$super());
	var self = this;

	if(parent)
		this.parent = parent;

	this.name = nodeData.name;

}

function Folder(parent, nodeData) {
	$.extend(this, new this.$super(parent, nodeData));

	var template = "<div class='folder'></div>"
	var element = $(template);

	var containerTemplate = "<div class='folder-items'></div>";
	var childContainer = $(containerTemplate);

	element.append(childContainer);

	var children = [];

	if(nodeData.children)
	{
		for(var i = 0; i < nodeData.children.length; i++)  {
			var childNodeData = nodeData.children[i];
			if(childNodeData.type == 'folder')
				children.push(new Folder(this, childNodeData))
			else
				children.push(new Item(this, childNodeData))

			// append child
			childContainer.append(children[i].element);
		}
	}	

	this.element = element;
	this.childContainer = childContainer;
	this.type = "folder"
	this.children = children;
	element.prepend('<p><i class="icon-folder-open"></i> ' + this.name + '</p>')
}

function Item(parent, nodeData) {
	$.extend(this, new this.$super(parent, nodeData));
	
	var template = "<div class='folder-item'></div>"
	var element = $(template);

	element.append('<p class=""><i class="icon-file"></i> ' + this.name + '</p>')

	this.element = element;
	this.type = "item"
}


function FolderView(nodeData) {
	$.extend(this, new this.$super());
	this.root = new Folder(null, nodeData)
	var self = this;

	this.appendTo = function(jq) {
		$(jq).append(self.root.element)
	}
}

Node.prototype.$super = EventDispatcher;
Folder.prototype.$super = Node;
Item.prototype.$super = Node;
FolderView.prototype.$super = EventDispatcher;


return FolderView

})();