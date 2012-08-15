function EventDispatcher() {

	var eventHandlers = {}

	function on(evtName, handler) {
		eventHandlers[evtName] = eventHandlers[evtName] || []
		eventHandlers[evtName].push(handler)
	}

	function off(evtName, handler)  {
		eventHandlers[evtName] = eventHandlers[evtName] || []
		for(var i = 0; i < eventHandlers[evtName].length;)
		{
			var target = eventHandlers[evtName][i]
			if(handler == target)
				eventHandlers[evtName].splice(i,1)
			else
				i++;
		}
	}

	function trigger(evtName) {
		
		var args = [].splice.call(arguments,0,1)
		var handlers = eventHandlers[evtName]

		if(!handlers)
			return

		for(var i = 0; i < handlers.length; i++)  {
			handlers[i].apply(this, args)
		}
	}

	function clear(evtName)  {
		if(evtName)
			eventHandlers[evtName] = []
		else 
			eventHandlers = {}
	}

	this.on = on;
	this.off = off;
	this.clear = clear;
	this.trigger = trigger;
}

(function test() {
	function assert(expr)  {
		if(!expr)
			alert('failed assertion')
	}
	var dummy = new EventDispatcher();
	var subject = 0;
	function a() { subject ++; }
	function aa() { subject *=2; }

	dummy.on("a",  a)
	dummy.trigger("a")
	dummy.trigger("a")
	assert(subject == 2)
	dummy.on("a", aa )
	dummy.off("a", a)
	dummy.trigger("a")
	assert(subject == 4)
	dummy.clear()
	dummy.trigger("a")
	assert(subject == 4)
	
})()