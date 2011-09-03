package components.tabviews
{
import components.Component;
import components.Composite;
import components.IComponent;
import components.INameableComponent;

import eventing.eventdispatchers.ISelectionChangeEventDispatcher;
import eventing.events.NameChangeEvent;
import eventing.events.SelectionChangeEvent;

import mx.collections.ArrayCollection;
import mx.containers.TabNavigator;
import mx.core.IVisualElementContainer;
import mx.events.ChildExistenceChangedEvent;
import mx.events.IndexChangedEvent;

import spark.components.NavigatorContent;

public class TabView extends Component implements ISelectionChangeEventDispatcher
{
	private var tn:TabNavigator = new TabNavigator();
	
	public function TabView()
	{
		super();
		tn.percentWidth = 100;
		tn.percentHeight = 100;
		
		visualElement = tn;
		visualElementContainer = tn;
		
		var self:TabView = this;
		
		tn.addEventListener(IndexChangedEvent.CHANGE,
			function(e:IndexChangedEvent):void
			{
				trace('index changed');
				dispatchSelectionChangeEvent(e.oldIndex, e.newIndex);
				for each(var child:IComponent in children)
				{
					if(child === selectedComponent)  {
						if(!(child as Component).hasFocus)
							dispatchComponentFocusInEvent(child as Component);
					}
					else
						dispatchComponentFocusOutEvent(child as Component);
				}
			}
		);
		
		
		
		
		
		addChildAddedEventListener(
			function():void
			{
				trace('child added');
//				dispatchSelectionChangeEvent();
			}
		);
		
		addChildRemovedEventListener(
			function():void
			{
				trace('child removed');
//				dispatchSelectionChangeEvent();
			}
		);
		

	}
	
	override protected function addChild(child:Composite):Composite
	{
		return super.addChild(child);
	}
	
	override protected function removeChild(child:Composite):Composite
	{
		return super.removeChild(child);
		
	}
	
	override protected function addChildTo(visualElementContainer:IVisualElementContainer, component:IComponent):void
	{
		var nameablecomp:INameableComponent = component as INameableComponent;
		
		var nc:NavigatorContent = new NavigatorContent();
		nc.percentHeight = 100;
		nc.percentWidth = 100;
		visualElementContainer.addElement(nc);
		super.addChildTo(nc, component);
		
		if(nameablecomp)  {
			nc.label = nameablecomp.name;	
			nameablecomp.addNameChangeEventListener( function(e:NameChangeEvent):void
				{
					nc.label = e.name;		
				}
			);
		}
		
		
	}
	
	override protected function removeChildFrom(visualElementContainer:IVisualElementContainer, component:IComponent):void
	{
		var nameablecomp:INameableComponent = component as INameableComponent;
		
		var nc:NavigatorContent = removeFromParent(component as Component) as NavigatorContent;
		visualElementContainer.removeElement(nc);	
		
		if(nameablecomp)
			removeAllEventListeners(NameChangeEvent.NAME_CHANGE);
		
	}
	
	public function addSelectionChangeEventListener(listener:Function):void
	{
		addEventListener(SelectionChangeEvent.SELECTION_CHANGE, listener);
	}
	
	public function removeSelectionChangeEventListener(listener:Function):void
	{
		removeEventListener(SelectionChangeEvent.SELECTION_CHANGE, listener);
	}
	
	protected function dispatchSelectionChangeEvent(oldSelectedIndex:int, selectedIndex:int):void
	{
		dispatchEvent(new SelectionChangeEvent(this, oldSelectedIndex, selectedIndex));
	}
	
	public function get selectedIndex():int
	{
		return tn.selectedIndex;
	}
	
	public function set selectedIndex(val:int):void
	{
		tn.selectedIndex = val;
	}
	
	protected function get selectedComponent():IComponent
	{
		return children[ selectedIndex ] as IComponent;
	}
	
	
}
}