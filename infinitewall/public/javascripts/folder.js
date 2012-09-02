/// TODO
/*
*  create wall/folder
*  selected node
*  
*
*/
var FolderView = (function() {

// sample nodeData
// {type: "folder", name:"study", children:[{type:"folder", name:"0201", children:[]}]}

function Node(parent, nodeData) {
	Node.prototype.$super.apply(this, [parent, nodeData])

	var self = this;

	if(parent)
		this.parent = parent;

	this.name = nodeData.name;
	this.isSelected = nodeData.false;
	this.on('selected', function() {
		console.log('selected', self)
		self.isSelected = true;
		$(self.element).addClass('selected')
		
	})

	this.on('deselected', function() {
		console.log('deselected', self)
		self.isSelected = false;
		$(self.element).removeClass('selected')
		
	})

	this.on('focus', function() {
		console.log('focus', self)
		if(self.children)  {
			for(var i = 0; i < self.children.length; i++)  {
				var child = self.children[i];
				child.trigger('unfocus')
			}
		}
		self.trigger('selected')
		
	})

	this.on('unfocus', function() {
		console.log('unfocus', self)
		if(self.children)  {
			for(var i = 0; i < self.children.length; i++)  {
				var child = self.children[i];
				child.trigger('unfocus')
			}
		}
		self.trigger('deselected')
		
	})

	this.on('childFocus', function(target) {
		console.log('childFocus', self, target)
		self.trigger('deselected')

		if(self == target)
			return;

		for(var i = 0; i < self.children.length; i++ )  {
			if(self.children[i] == target)
				continue;
			self.children[i].trigger('unfocus')
		}
		
	})


}

function Folder(parent, nodeData) {
	Folder.prototype.$super.apply(this, [parent, nodeData])
	//$.extend(this, new this.$super(parent, nodeData));

	var template = "<div class='folder'></div>"
	var element = $(template);
	var self = this;


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
			// listen for events

			children[i].on('focus', function(child) {
				self.trigger('childFocus', child)
			});

			(function(c) {
				children[i].on('childFocus', function(child) {
					self.trigger('childFocus', c)
				});
			})(children[i])

			children[i].on('unfocus', function() { 
				this.trigger('childUnfocus') 
			});
		}
	}	

	this.element = element;
	this.childContainer = childContainer;
	this.type = "folder"
	this.children = children;
	element.prepend('<p><i class="icon-folder-open"></i> ' + this.name + '</p>')

	$(this.element).on('click', function(e) {
		self.trigger('focus', self)
		e.stopPropagation();
	})
}

function Item(parent, nodeData) {
	Item.prototype.$super.apply(this, [parent, nodeData])
	//$.extend(this, new this.$super(parent, nodeData));
	
	var template = "<div class='folder-item'></div>"
	var element = $(template);
	var self = this;

	element.append('<p class=""><i class="icon-file"></i> ' + this.name + '</p>')

	this.element = element;
	this.type = "item"

	$(this.element).on('click', function(e) {
		self.trigger('focus', self)
		e.stopPropagation();
	})
}


function FolderView(nodeData) {
	FolderView.prototype.$super.apply(this, [nodeData])
	// $.extend(this, new this.$super());

	this.selectedNodes = [];
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