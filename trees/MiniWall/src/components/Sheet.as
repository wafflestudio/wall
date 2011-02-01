package components  {

import flash.display.Graphics;
import flash.events.Event;

import spark.components.BorderContainer;
import spark.components.TextArea;
import behaviors.capabilities.Movability;
import flash.events.MouseEvent;
import components.interfaces.IContent;
import flash.events.FocusEvent;
import spark.layouts.VerticalLayout;
import components.controls.CloseButton;
import behaviors.events.ChildrenEvent;
import behaviors.capabilities.Resizability;
import mx.events.ResizeEvent;

/** Sheet: 시트 컴포넌트. 
 * 
 * Wall상에 놓이고 컨텐트를 담는다 
 * 
 * 벽 상에서 움직이고, (moving, moved)
 * 사이즈가 조절되고 	(resizing, resized)
 * 컨텐트 줌 인/아웃이 된다  (zooming, zommed)
 * 
 * 시트 자체로 드래그가 되고
 * 리사이즈 컨트롤이 부착되어 있고
 * 줌 컨트롤이 부착되어 있다
 * 
 * 생성과 삭제
 * 
 * */
[Event(name="moving", type="flash.events.Event")]
[Event(name="moved", type="flash.events.Event")]
[Event(name="resizing", type="flash.events.Event")]
[Event(name="resized", type="flash.events.Event")]
[Event(name="zooming", type="flash.events.Event")]
[Event(name="zoomed", type="flash.events.Event")]
public class Sheet extends SpatialObject
{
	public static const TEXT_CONTENT:String = "text";
	public static const IMAGE_CONTENT:String = "image";
	
	private var type:String;
	
	public static function create(sheetXML:XML):Sheet  {
		var new_sheet:Sheet = new Sheet();
		
		new_sheet.x = sheetXML.@x;
		new_sheet.y = sheetXML.@y;
		new_sheet.width = sheetXML.@width;
		new_sheet.height = sheetXML.@height;
		new_sheet.type = sheetXML.@type;
		
		switch(new_sheet.type)  {
			case TEXT_CONTENT:
				var tc:TextContent = new TextContent(sheetXML.text); 
				new_sheet.addElement(tc);
				// prevent events
				tc.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void { e.stopPropagation(); });
				
				break;
			case IMAGE_CONTENT:
				new_sheet.addElement(new ImageContent(String(sheetXML.@url)));
				break;
			default:
				trace('unknown type attribute found:' + String(sheetXML.@type));
		}
		
		
		return new_sheet;
	}

	private var movability:Movability;
	private var resizability:Resizability;
	
	
	public function Sheet()  {
		super();
		movability = new Movability(this);
		resizability = new Resizability(this);
		this.addEventListener(MouseEvent.MOUSE_DOWN, bringToFront, false, 1);
		// force focus to content
		this.addEventListener(FocusEvent.FOCUS_IN, focus);
	}
	
	private function focus(e:FocusEvent):void
	{
		for(var i:int = 0; i < this.numElements; i ++)  {
			var content:IContent = (this.getElementAt(i) as IContent);
			if(content)  {
				content.setFocus();
				break;
			}
		}
	}
	 
	public function toXML():XML  {
		var xml:XML = <sheet/>;
		xml.@x = this.x;
		xml.@y = this.y;
		xml.@width = this.width;
		xml.@height = this.height;
		xml.@type = this.type;
		
		// read content
		switch(this.type)  {
			case TEXT_CONTENT:
				for(var i:int  = 0; i < this.numElements; i++)  {
					var element:IContent = this.getElementAt(i) as IContent;
					if(element)
						xml.appendChild(element.toXML());
				}
				break;
			case IMAGE_CONTENT:
				break;
			default:
				trace('unknown type attribute:' + this.type);
		}
		
		return xml;
	}
	
	/** initialize()
	 * 
	 * 컴포넌트 초기화
	 * 
	 * initialize sevents
	 *  
	 * 
	 **/
	public override function initialize():void  {
		super.initialize();
		// set layout (padding)
		var layout:VerticalLayout = new VerticalLayout();
		layout.paddingRight = layout.paddingBottom = layout.paddingTop = layout.paddingLeft = 10;
		this.layout = layout;
	
	}
	
	/** createChildren:
	 * 
	 * 자식 노드 생성
	 * 
	 * */
	protected override function createChildren():void  {
		super.createChildren();	
		
		var closeButton:CloseButton = new CloseButton();
		closeButton.includeInLayout = false;
		this.addElement(closeButton);
		
		this.addEventListener(ResizeEvent.RESIZE, function onResize(e:ResizeEvent):void  {
			closeButton.x = width - closeButton.width;
		});
		
		closeButton.addEventListener(MouseEvent.CLICK, 
			function clickHandler(e:Event):void  {
				dispatchEvent(new ChildrenEvent(ChildrenEvent.CLOSE_ACTION));
			}
		);
	}

	
	
}
}