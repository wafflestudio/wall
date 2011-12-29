/**
 * Created by IntelliJ IDEA.
 * User: kindone
 * Date: 11. 12. 15.
 * Time: 오전 11:15
 * To change this template use File | Settings | File Templates.
 */

package cream.components.docks {
import cream.components.FlexibleComponent;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;

import mx.graphics.BitmapFill;
import mx.graphics.SolidColor;

import spark.components.BorderContainer;
import spark.components.VGroup;
import spark.layouts.VerticalLayout;

public class Dock extends FlexibleComponent {

    private var bc:BorderContainer = new BorderContainer();
    private var vgroup:VGroup = new VGroup();
    private var titleBar:BorderContainer = new BorderContainer();

    override protected function get visualElement():IVisualElement {  return bc;  }
    override protected function get visualElementContainer():IVisualElementContainer	{  return bc;	}


    override protected function get moveControl():IVisualElement  { return titleBar; }


    public function Dock() {

        titleBar.backgroundFill = new SolidColor(0);
        titleBar.percentWidth = 100;
        titleBar.height = 26;
        vgroup.percentHeight = 100;
        vgroup.percentWidth = 100;

        bc.addElement(vgroup);
        vgroup.addElement(titleBar);

    }
}
}
