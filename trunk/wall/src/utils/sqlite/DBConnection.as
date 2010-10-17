package utils.sqlite  {
import mx.rpc.events.FaultEvent;
	
public class DBConnection
{
	private var sqlConnection:SQLConnection;
	public function DBConnection()
	{
		var databaseFile:File = File.applicationStorageDirectory.resolveFile("dbname.db");
		sqlConnection = new SQLConnection();
		sqlConnection.addEventListener(Event.OPEN, openHandler);
		sqlConnection.openAsync(databaseFile);
		
	}
	
	private function connectResultHandler(e:Event):void
	{
		var statement:SQLStatement = new SQLStatement();
		statement.sqlConnection = sqlConnection;
		statement.text = "CREATE TABLE IF NOT EXISTS inventory(" + "id INTEGER PRIMARY KEY AUTOINCREMENT, " + "title TEXT, isbn TEXT, count INTEGER)";
		statement.execute();
	}
	
	private function failHandler(e:FaultEvent):void
	{
		
	}
}
}