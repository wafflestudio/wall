/**
 * Created by IntelliJ IDEA.
 * User: kindone
 * Date: 11. 12. 30.
 * Time: 오후 11:20
 * To change this template use File | Settings | File Templates.
 */
package cream.components.sheets {
import cream.components.contents.ImageContent;
import cream.eventing.events.CommitEvent;
import cream.eventing.events.ResizeEvent;
import cream.storages.IXMLizable;

import flash.filesystem.File;

public class ImageSheet extends Sheet{

    private var imageContent:ImageContent;
    
    
    public function get file():File { return imageContent.file; }
    public function set file(value:File):void { imageContent.file = value;}

    public function ImageSheet() {
        super(Sheet.IMAGE_SHEET);

        addResizedEventListener( function(e:ResizeEvent)
        {
            imageContent.width = e.right - e.left;
            imageContent.height = e.bottom - e.top;
        })
    }

    override protected function initUnderlyingComponents():void
    {
        super.initUnderlyingComponents();

        imageContent = new ImageContent();
        bc.addElement(imageContent._protected_::visualElement);

        imageContent.addCommitEventListener( function(e:CommitEvent):void
        {
            dispatchCommitEvent(e);
        });
    }

    public override function set width(val:Number):void
    {
        imageContent.width = val;
        super.width = val;
    }

    public override function set height(val:Number):void
    {
        imageContent.height = val;
        super.height = val;
    }


    /**
     * 	<sheet x="" y="" width="" height="">
     * 		<content>
     * 			...
     * 		</content>
     * 	</sheet>
     */
    override public function fromXML(xml:XML):IXMLizable
    {
        super.fromXML(xml);

        if(xml.child("content")[0] != null) {
            var contentXML:XML = xml.content[0];
            imageContent.fromXML(contentXML);
            imageContent.width = width;
            imageContent.height = height;
        }
        return this;
    }

    override public function toXML():XML
    {
        var xml:XML = super.toXML();
        xml.appendChild(imageContent.toXML());

        return xml;
    }

}
}
