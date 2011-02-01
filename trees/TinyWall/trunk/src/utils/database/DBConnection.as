package utils.database  {
import mx.rpc.events.FaultEvent;
import flash.data.SQLConnection;
import flash.events.SQLEvent;
import flash.events.Event;
import flash.events.SQLErrorEvent;

public class DBConnection
{
	private var sqlConnection:SQLConnection;
	public function DBConnection()
	{
		
	}
	
	private function openDB(filename:String):void
	{
		var databaseFile:File = File.applicationStorageDirectory.resolveFile(filename);
		sqlConnection = new SQLConnection();
		sqlConnection.addEventListener(SQLEvent.OPEN, openHandler);
		sqlConnection.addEventListener(SQLErrorEvent.ERROR, failHandler);
		sqlConnection.openAsync(databaseFile);
	}
	
	private function connectResultHandler(e:Event):void
	{
		var statement:SQLStatement = new SQLStatement();
		statement.sqlConnection = sqlConnection;
		statement.text = "CREATE TABLE IF NOT EXISTS inventory(" + "id INTEGER PRIMARY KEY AUTOINCREMENT, " + "title TEXT, isbn TEXT, count INTEGER)";
		statement.execute();
	}
	
	private function openHandler(e:SQLEvent):void
	{
		
	}
	
	private function failHandler(e:FaultEvent):void
	{
		
	}
}
}