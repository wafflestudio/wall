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
import eventing.events.CloseEvent;
import eventing.events.CompositeEvent;
import eventing.events.NameChangeEvent;
import eventing.events.SelectionChangeEvent;
import eventing.events.TabCloseEvent;

import flash.display.DisplayObject;

import mx.collections.ArrayCollection;
import mx.containers.TabNavigator;
import mx.containers.ViewStack;
import mx.core.IVisualElement;
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
		
		vgroup.addElement(tabBar._protected_::visualElement);
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
		
		tabBar.addCloseEventListener( function(e:TabCloseEvent):void
			{
				var child:Component = children[e.index];
				removeChild(child);
			}
		);
		
	}
	
	override protected function addChild(child:Composite):Composite
	{
		
		var component:Component = child as Component;

		var nc:NavigatorContent = new NavigatorContent();
		nc.percentHeight = 100;
		nc.percentWidth = 100;
		nc.addElement(component._protected_::visualElement);
		
		viewStack.addElement(nc);
		
		var button:TabButton = new TabButton();
		button.label = "unnamed"; 
		tabBar.addButton(button);

		var nameablecomp:INameableComponent = component as INameableComponent;
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
		
		super.addChild(child);
		
		return child;
	}
	
	override protected function removeChild(child:Composite):Composite
	{
		var component:Component = child as Component;
		var index:int = getChildIndex(component);
		var nameablecomp:INameableComponent = component as INameableComponent;
		
		for(var i:int = 0 ; i <  visualElementContainer.numElements; i++)  {
			var nc:NavigatorContent = visualElementContainer.getElementAt(i) as NavigatorContent;
			if(!nc)
				continue;
			if(nc.contains(component._protected_::visualElement as DisplayObject))  {
				nc.removeElement(component._protected_::visualElement);
				visualElementContainer.removeElement(nc);
			}
			
		}		
		if(nameablecomp)
			removeAllEventListeners(NameChangeEvent.NAME_CHANGE);
		
		tabBar.removeButton(tabBar._protected_::children[index]);
		
		super.removeChild(child);
		
		tabBar.selectedIndex = viewStack.selectedIndex;
		
		return child;
	}
	
	override protected function attachSparkElement(sparkElement:IVisualElement):void
	{
		// no effect. first, navigator content is attached, and sparkElement is attached to the navigator content
	}
	
	override protected function detachSparkElement(sparkElement:IVisualElement):void
	{
		// no effect.		
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
		return viewStack.selectedIndex;
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