define ["./operation"], (Operation) ->
	class CharWithState
		constructor: (@c, @insertedBy = {}, @deletedBy = {}) ->

			
		setDeletedBy: (branch) ->
			@deletedBy[branch] = true
		setInsertedBy: (branch) ->
			@insertedBy[branch] = true
		
		
	class StringWithState
		constructor:(str)->
			i = 0
			@list = []
			while i < str.length
				@list.push(new CharWithState(str.charAt(i)))
				i++

		apply:(op, branch) ->
			i = 0
			iBranch = 0
			insertPos = 0
			alteredFrom = 0
			numDeleted = 0
			iAtIBranch = 0

			@list = for cs in @list
				if !cs.deletedBy[branch] && (Object.keys(cs.insertedBy).length == 0 || cs.insertedBy[branch])
					if iBranch >= op.from && iBranch < op.from + op.length
						if Object.keys(cs.deletedBy).length == 0
							numDeleted++
						cs.deletedBy[branch] = true
						insertPos = i
					else if iBranch == op.from + op.length
						insertPos = i
					iBranch++
					iAtIBranch = i+1
				i++
				cs

			if iBranch <= op.from
				insertPos = iAtIBranch

			inserted = for c in op.content
				insertedBy = {}
				insertedBy[branch] = true
				new CharWithState(c, insertedBy)
			
			i = 0
			for cs in @list
				if i < insertPos
					if Object.keys(cs.deletedBy).length == 0
						alteredFrom++
				i++

			@list = @list.slice(0, insertPos).concat(inserted).concat(@list.slice(insertPos))
			new Operation(alteredFrom, numDeleted, op.content, op.range)

		clone:() ->
			ss = new StringWithState("")
			ss.list = for cs in @list
				insertedBy = {}
				deletedBy = {}
				for k,v of cs.insertedBy
					insertedBy[k] = v
				for k,v of cs.deletedBy
					deletedBy[k] = v

				new CharWithState(cs.c, insertedBy, deletedBy)
			ss


		text:() ->
			text = ""
			i = 0
			while i < @list.length
				cs = @list[i]
				if Object.keys(cs.deletedBy).length == 0
					text += cs.c
				i++
			text

		html:() ->
			html = ""
			i = 0
			while i < @list.length
				cs = @list[i]
				classes = []
				if Object.keys(cs.deletedBy).length > 0
					classes.push('deleted')
				if Object.keys(cs.insertedBy).length > 0
					classes.push('inserted')
				branches = {}
				for b,v of cs.deletedBy
					branches[b] = true
				for b,v of cs.insertedBy
					branches[b] = true
				for b,v of branches
					classes.push("b#{b}")
				# if cs.deletedBy[A] || cs.deletedByA
				#     classes.push('A')
				# if cs.insertedByB || cs.deletedByB
				#     classes.push('B')

				if classes.length > 0
					html = html + "<span class='#{classes.join(' ')}'>#{cs.c}</span>"
				else
					html = html + cs.c

				i++

			html

