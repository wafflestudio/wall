/**
 * Created by IntelliJ IDEA.
 * User: kindone
 * Date: 11. 12. 25.
 * Time: 오후 2:06
 * To change this template use File | Settings | File Templates.
 */

package cream.components.walls {
import mx.core.IVisualElementContainer;

import spark.components.BorderContainer;

public class RemoteWall extends Wall {

    private var url:String;

    protected var wrapper:BorderContainer;
    
    override protected function get visualElementContainer():IVisualElementContainer { return wrapper; }

    public function RemoteWall() {
        super();
    }

    override protected function initUnderlyingComponents():void
    {
        super.initUnderlyingComponents();
        wrapper = new BorderContainer();
        
        wrapper.addElement(bc);
    }

}
}
