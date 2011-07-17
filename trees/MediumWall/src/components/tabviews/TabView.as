package components.tabviews
{
import components.IComponent;
import mx.containers.TabNavigator;
import components.Component;
import mx.collections.ArrayCollection;
import mx.core.IVisualElementContainer;
import eventing.events.INameChangeEvent;
import mx.events.IndexChangedEvent;
import eventing.events.SelectionChangeEvent;
import eventing.events.ISelectionChangeEvent;
import eventing.events.NameChangeEvent;
import spark.components.NavigatorContent;
import components.INameableComponent;
import mx.events.ChildExistenceChangedEvent;
import components.IComposite;

public class TabView extends Component implements ITabView
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
				dispatchSelectionChangeEvent(new SelectionChangeEvent(self, selectedIndex, selectedComponent));
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
				dispatchSelectionChangeEvent();
			}
		);
		
		addChildRemovedEventListener(
			function():void
			{
				trace('child removed');
				dispatchSelectionChangeEvent();
			}
		);
		

	}
	
	override public function addChild(child:IComposite):IComposite
	{
		return super.addChild(child);
	}
	
	override public function removeChild(child:IComposite):IComposite
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
			nameablecomp.addNameChangeEventListener( function(e:INameChangeEvent):void
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
	
	protected function dispatchSelectionChangeEvent(e:ISelectionChangeEvent = null):void
	{
		if(e == null)
			e = new SelectionChangeEvent(this, selectedIndex, selectedComponent);
		dispatchEvent(e);
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