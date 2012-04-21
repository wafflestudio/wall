/**
 * Created by IntelliJ IDEA.
 * User: kindone
 * Date: 11. 12. 15.
 * Time: 오전 11:15
 * To change this template use File | Settings | File Templates.
 */

package cream.components.docks {
import cream.components.Component;
import cream.components.FlexibleComponent;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.graphics.SolidColor;

import spark.components.BorderContainer;
import spark.components.VGroup;

public class Dock extends Component {

    private var bc:BorderContainer;
    private var vgroup:VGroup;
    private var titleBar:BorderContainer;

    override protected function get visualElement():IVisualElement {  return bc;  }
    override protected function get visualElementContainer():IVisualElementContainer	{  return vgroup;	}

//
//    override protected function get moveControl():IVisualElement  { return titleBar; }


    public function Dock() {
        super();

    }

    override protected function initUnderlyingComponents():void
    {

        bc = new BorderContainer();
        vgroup = new VGroup();
        titleBar = new BorderContainer();

        titleBar.backgroundFill = new SolidColor(0xcccccc);
        titleBar.percentWidth = 100;
        titleBar.height = 26;
        titleBar.name = "Chat";
        vgroup.percentHeight = 100;
        vgroup.percentWidth = 100;

        bc.addElement(vgroup);
        vgroup.addElement(titleBar);

    }
}
}
