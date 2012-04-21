/**
 * Created by IntelliJ IDEA.
 * User: kindone
 * Date: 11. 12. 25.
 * Time: 오후 7:08
 * To change this template use File | Settings | File Templates.
 */
package cream.components.dialogs {

public class ChatDialog extends Dialog {
    public function ChatDialog() {
        super();
        title = "Chat";
    }

    override protected function initUnderlyingComponents():void
    {
        super.initUnderlyingComponents();
        tw.width = 400;
        tw.height = 600;

    }
}
}
