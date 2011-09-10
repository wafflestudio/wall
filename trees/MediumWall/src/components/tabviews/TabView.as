package components.tabviews
{
import components.Component;
import components.Composite;
import components.IComponent;
import components.INameableComponent;
import components.buttonbars.TabBar;
import components.buttons.Button;
import components.buttons.TabButton;

import eventing.eventdispatchers.ISelectionChangeEventDispatcher;
import eventing.events.CompositeEvent;
import eventing.events.NameChangeEvent;
import eventing.events.SelectionChangeEvent;

import flash.display.DisplayObject;

import mx.collections.ArrayCollection;
import mx.containers.TabNavigator;
import mx.containers.ViewStack;
import mx.core.IVisualElementContainer;
import mx.events.ChildExistenceChangedEvent;
import mx.events.IndexChangedEvent;

import spark.components.NavigatorContent;
import spark.components.VGroup;

public class TabView extends Component implements ISelectionChangeEventDispatcher
{
	private var vgroup:VGroup = new VGroup();
	private var tabBar:TabBar = new TabBar();
	private var viewStack:ViewStack = new ViewStack();
	
	public function TabView()
	{
		super();
		
		vgroup.percentWidth = 100;
		vgroup.percentHeight = 100;
		
		addChildTo(vgroup, tabBar);
		tabBar.percentWidth = 100;
		
		vgroup.addElement(viewStack);
		viewStack.percentHeight = 100;
		viewStack.percentWidth = 100;
		
		visualElement = vgroup;
		visualElementContainer = viewStack;
		
		var self:TabView = this;
		
		tabBar.addSelectionChangeEventListener(
			function(e:SelectionChangeEvent):void
			{
				viewStack.selectedIndex = e.selectedIndex;
				
				dispatchSelectionChangeEvent(e.oldSelectedIndex, e.selectedIndex);
				for each(var child:Component in children)
				{
					if(child === selectedComponent)  {
						if(!child.hasFocus)
							dispatchComponentFocusInEvent(child);
					}
					else
						dispatchComponentFocusOutEvent(child);
				}
			}
		);
		
		tabBar.addChildRemovedEventListener( function(e:CompositeEvent):void
			{
				
				removeChild(children[e.index]);
				//viewStack.removeChildAt(e.index);
				
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
		if(visualElementContainer == viewStack)  {
			var nameablecomp:INameableComponent = component as INameableComponent;
			
			var nc:NavigatorContent = new NavigatorContent();
			nc.percentHeight = 100;
			nc.percentWidth = 100;
			
			viewStack.addElement(nc);
			super.addChildTo(nc, component);
			
			var button:TabButton = new TabButton();
			button.label = "unnamed"; 
			tabBar.addButton(button);
			
			if(nameablecomp)  {
				nc.label = nameablecomp.name;	
				button.label = nc.label;
				nameablecomp.addNameChangeEventListener( function(e:NameChangeEvent):void
					{
						nc.label = e.name;
						button.label = e.name;
					}
				);
			}
		}
		else 
			super.addChildTo(visualElementContainer, component);
		
	}
	
	override protected function removeChildFrom(visualElementContainer:IVisualElementContainer, component:Component):void
	{
		if(visualElementContainer == viewStack)  {
			var nameablecomp:INameableComponent = component as INameableComponent;
			
			for(var i:int = 0 ; i <  visualElementContainer.numElements; i++)  {
				var nc:NavigatorContent = visualElementContainer.getElementAt(i) as NavigatorContent;
				if(!nc)
					continue;
				if(nc.contains(component._::visualElement as DisplayObject))  {
					super.removeChildFrom(nc, component);
					visualElementContainer.removeElement(nc);
				}
			
			}		
			if(nameablecomp)
				removeAllEventListeners(NameChangeEvent.NAME_CHANGE);
		}
		else
			super.removeChildFrom(visualElementContainer, component);
		
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
		return tabBar.selectedIndex;
	}
	
	public function set selectedIndex(val:int):void
	{
		tabBar.selectedIndex = val;
		viewStack.selectedIndex = val;
	}
	
	protected function get selectedComponent():IComponent
	{
		return children[ selectedIndex ] as IComponent;
	}
	
	
}
}