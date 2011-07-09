package eventing.events
{
public interface IScrollEvent extends IEvent
{
	function get horitontalScrollPosRatio():Number;
	function get horitontalScrollLengthRatio():Number;
	function get verticalScrollPosRatio():Number;
	function get verticalScrollLengthRatio():Number;
}
}