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
		
		var args = []
		for(var i = 1; i < arguments.length; i++)
			args.push(arguments[i]) 
		
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
	function assert(expr,msg)  {
		if(!expr)
			alert('failed assertion: ' + msg)
	}
	var dummy = new EventDispatcher();
	var subject = 0;
	var args = []
	function a(ar) { subject ++; args.push(ar);}
	function aa(ar) { subject *=2; args.push(ar);}

	dummy.on("a",  a)
	dummy.trigger("a", 1)
	dummy.trigger("a", 2)
	assert(subject == 2, "subject == 2: " + subject)
	//assert(args == [1,2])
	dummy.on("a", aa )
	dummy.off("a", a)
	dummy.trigger("a")
	assert(subject == 4)
	dummy.clear()
	dummy.trigger("a")
	assert(subject == 4)
	
})()