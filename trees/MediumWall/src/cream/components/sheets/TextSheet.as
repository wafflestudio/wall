/**
 * Created by IntelliJ IDEA.
 * User: kindone
 * Date: 11. 12. 30.
 * Time: 오후 11:20
 * To change this template use File | Settings | File Templates.
 */
package cream.components.sheets {
import cream.components.contents.TextContent;
import cream.eventing.events.CommitEvent;
import cream.storages.IXMLizable;

public class TextSheet extends Sheet{
    private var textContent:TextContent;

    public function get text():String { return textContent.text; }
    public function set text(value:String):void { textContent.text = value;}

    public function TextSheet() {
        super(Sheet.TEXT_SHEET);
    }

    override protected function initUnderlyingComponents():void
    {
        super.initUnderlyingComponents();

        textContent = new TextContent();
        bc.addElement(textContent._protected_::visualElement);
        textContent.addCommitEventListener( function(e:CommitEvent):void
        {
            dispatchCommitEvent(e);
        });
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
            textContent.fromXML(contentXML);
        }
        return this;
    }

    override public function toXML():XML
    {
        var xml:XML = super.toXML();
        xml.appendChild(textContent.toXML());

        return xml;
    }
}
}
