package utils.database
{
/** Thoughts: 
 * 모든 것이 객체로 나뉠 필요가 없다.
 * procedure같은 추상적인 대상은 객체가 오히려 잘 어울리지 않을 수 있다.
 * 
 * Sync냐 Async냐의 문제가 있다. resultHandler같은걸 둘 수도 있을 것이다.
 * **/
public class Database
{
	public function Database()
	{
		
	}
	
	public function save(schema:DBSchema, data:DBData, stateUpdateHandler:Function):void
	{
		
	}
	
	public function load(schema:DBSchema, data:DBData, stateUpdateHandler:Function):void
	{
		
	}
}
}