/**
 * Created by IntelliJ IDEA.
 * User: kindone
 * Date: 11. 12. 25.
 * Time: 오후 2:06
 * To change this template use File | Settings | File Templates.
 */

package cream.components.walls {
import cream.components.docks.Dock;
import cream.components.walls.FileStoredWall;

import mx.core.IVisualElementContainer;

import spark.components.BorderContainer;

public class SynchronizableWall extends FileStoredWall {

    private var syncURL:String;

    protected var chatDock:Dock;

    public function SynchronizableWall() {
        super();
    }

    override protected function initUnderlyingComponents():void
    {
        super.initUnderlyingComponents();
        chatDock = new Dock();
        chatDock.width = 200;
        chatDock.percentHeight = 100;
        bc.addElement(chatDock._protected_::visualElement);
    }

}
}
