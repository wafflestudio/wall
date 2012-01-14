/**
 * Created by IntelliJ IDEA.
 * User: kindone
 * Date: 12. 1. 14.
 * Time: 오후 8:04
 * To change this template use File | Settings | File Templates.
 */
package cream.components {
import flash.filesystem.File;

public interface IFileStoredComponent {
    function get relativePath():File;
}
}
