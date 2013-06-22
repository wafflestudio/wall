define  ["jquery", "rangy"], ($, rangy) ->

	class RangeUtil
		@setRange : (textfield, start, end) ->
			html = $(textfield).html()
			length = html.length

			backwards = start > end
			if start < end
				s = start
				e = end
			else
				s = end
				e = start

			if s == e
				html = html.substr(0,s) + '<a class="rangeCollapsed"></a>' + html.substr(s)
				$(textfield).html(html)
				node = $(textfield).find('a.rangeCollapsed').get(0)
				range = rangy.createNativeRange()
				if s > 0
					range.setEndBefore(node)
					range.collapse(false)
				else if e < length-1
					range.setStartAfter(node)
					range.collapse(true)
				else
					range.selectNode($(textfield).get(0))

				node.parentNode.removeChild(node)

			else
				$(textfield).html(html.substr(0,s) + '<a class="rangeStart"></a>' +
						html.substr(s, e-s) + '<a class="rangeEnd"></a>' + html.substr(e))
				node1 = $(textfield).find('a.rangeStart').get(0)
				node2 = $(textfield).find('a.rangeEnd').get(0)
				#console.log(node1, node2)
				range = rangy.createNativeRange()
				range.setStartAfter(node1)
				range.setEndBefore(node2)
				node1.parentNode.removeChild(node1)
				node2.parentNode.removeChild(node2)

			rangy.getSelection().removeAllRanges()
			rangy.getSelection().addRange(range, backwards)

		 
		@getRange : (textfield) ->
			start = 0
			end = 0

			# save rangy.getSelection()
			rangy.getSelection().refresh()
			ranges = rangy.getSelection().getAllRanges()

			if ranges.length == 0
				console.warn('no available rangy.getSelection() or cursor')
				return null

			range = ranges[0]
			backwards = rangy.getSelection().isBackwards()
			collapsed = rangy.getSelection().isCollapsed

			if !collapsed and backwards
				range4 = range.cloneRange()
				range4.collapse(false)
				endNode = document.createElement('a')
				endNode.setAttribute('class', 'rangeEnd')
				range4.insertNode(endNode)

			# insert node    [[inserted]            ]
			range2 = range.cloneRange()
			startNode = document.createElement('a')
			startNode.setAttribute('class', 'rangeStart')
			range2.insertNode(startNode)
			# get the position with innerHTML
			start = $(textfield).html().search('<a class="rangeStart"')
			# remove node
			startNode.parentNode.removeChild(startNode)

			rangy.getSelection().refresh()
			range = rangy.getSelection().getAllRanges()[0]

			if !collapsed and backwards
				rangy.getSelection().removeAllRanges()
				range.setEndBefore(endNode)
				endNode.parentNode.removeChild(endNode)
				rangy.getSelection().addRange(range,backwards)

			if collapsed
				end = start
			else
				# insert node at the end
				endNode = document.createElement('a')
				endNode.setAttribute('class', 'rangeEnd')
				range3 = range.cloneRange()
				range3.collapse(false)  # collapse to end
				range3.insertNode(endNode)

				# get the position with innerHTML
				end = $($(textfield)).html().search('<a class="rangeEnd"')
				# remove node
				endNode.parentNode.removeChild(endNode)
				rangy.getSelection().refresh()
				range = rangy.getSelection().getAllRanges()[0]

			# restore rangy.getSelection()
			rangy.getSelection().removeAllRanges()
			rangy.getSelection().addRange(range, backwards)
			
			[start, end, $(textfield).html().length]
