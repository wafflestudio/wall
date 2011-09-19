package cream.components
{
import cream.eventing.eventdispatchers.EventDispatcher;
import cream.eventing.eventdispatchers.ICompositeEventDispatcher;
import cream.eventing.events.CompositeEvent;

import mx.collections.ArrayCollection;

public class Composite extends EventDispatcher implements ICompositeEventDispatcher
{
	protected namespace _protected_ = "http://cream.wafflestudio.com";
	
	protected var parent:Composite;
	protected var children:ArrayCollection; 
	
	_protected_ function get parent():Composite { return parent; }
	_protected_ function get children():ArrayCollection { return children; }
	
	
	public function Composite()
	{
		super();
		children = new ArrayCollection([]);
	}
	
	protected function addChild(child:Composite):Composite
	{
		child.parent = this;
		children.addItem(child);
		child.dispatchAddedEvent();
		dispatchChildAddedEvent(child);
		return child;	
	}
	
	protected function removeChild(child:Composite):Composite
	{
		var index:int = children.getItemIndex(child);
		if(index >=0 )  {
			children.removeItemAt(index);
			(child as Composite).parent = null;
			(child as Composite).dispatchRemovedEvent();
			dispatchChildRemovedEvent(child, index);
			return child;
		}
		
		return null;
	}
	
	protected function removeAllChildren():void
	{
		for(var i:int = numChildren-1; i >=0; i --)
		{
			var child:Composite = children.removeItemAt(i) as Composite;
			child.parent = null;
		}
	}
	
	protected function getChildIndex(child:Composite):int
	{
		for(var i:int = 0; i < numChildren; i++)
		{
			if(child == children[i])
				return i;
		}
		
		return -1;
	}
	
	public function addChildAddedEventListener(listener:Function):void
	{
		addEventListener(CompositeEvent.CHILD_ADDED, listener);
	}
	
	public function removeChildAddedEventListener(listener:Function):void
	{
		removeEventListener(CompositeEvent.CHILD_ADDED, listener);
	}
	
	protected function dispatchChildAddedEvent(child:Composite):void
	{
		dispatchEvent(new CompositeEvent(this, CompositeEvent.CHILD_ADDED, child));
	}
	
	public function addChildRemovedEventListener(listener:Function):void
	{
		addEventListener(CompositeEvent.CHILD_REMOVED, listener);
	}
	
	public function removeChildRemovedEventListener(listener:Function):void
	{
		removeEventListener(CompositeEvent.CHILD_REMOVED, listener);
	}
	
	protected function dispatchChildRemovedEvent(child:Composite, index:int):void
	{
		dispatchEvent(new CompositeEvent(this, CompositeEvent.CHILD_REMOVED, child, index));
	}
	
	public function addAddedEventListener(listener:Function):void
	{
		addEventListener(CompositeEvent.ADDED, listener);
	}
	
	public function removeAddedEventListener(listener:Function):void
	{
		removeEventListener(CompositeEvent.ADDED, listener);
	}
	
	protected function dispatchAddedEvent(e:CompositeEvent = null):void
	{
		if(e == null)
			e = new CompositeEvent(this, CompositeEvent.ADDED);
		dispatchEvent(e);
	}
	
	public function addRemovedEventListener(listener:Function):void
	{
		addEventListener(CompositeEvent.REMOVED, listener);
	}
	
	public function removeRemovedEventListener(listener:Function):void
	{
		removeEventListener(CompositeEvent.REMOVED, listener);
	}
	
	protected function dispatchRemovedEvent(e:CompositeEvent = null):void
	{
		if(e == null)
			e = new CompositeEvent(this, CompositeEvent.REMOVED);
		dispatchEvent(e);
	}
	
	
	protected function get numChildren():int
	{
		return children.length;
	}
	
	protected function reset():void
	{
		removeAllChildren();
	}
}
}