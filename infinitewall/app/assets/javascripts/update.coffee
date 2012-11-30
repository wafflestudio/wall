
class Operation
    constructor: (@from, @length, @content) ->

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

        @list = for cs in @list
            if !cs.deletedBy[branch] && (Object.keys(cs.insertedBy).length == 0 || cs.insertedBy[branch])
                if iBranch >= op.from && iBranch < op.from + op.length
                    if Object.keys(cs.deletedBy).length == 0
                        numDeleted++
                    cs.deletedBy[branch] = true
                else if iBranch == op.from + op.length
                    insertPos = i
                iBranch++
            i++
            cs

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
        new Operation(alteredFrom, numDeleted, op.content)



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
            # if cs.deletedBy[A] || cs.deletedByA
            #     classes.push('A')
            # if cs.insertedByB || cs.deletedByB
            #     classes.push('B')

            if classes.length > 0
                html += "<span class='#{classes.join(' ')}'>#{cs.c}</span>"
            else
                html += cs.c

            i++

        html
                    
###
# Test
baseText = "baseText"
A = [new Operation(2,2,"in"), new Operation(2,2,""),new Operation(0,0,"newlyInserted"),new Operation(1,3,"")]
B = [new Operation(2,2,"or"), new Operation(3,1,"R"), new Operation(0,3,"")]
base = new StringWithState(baseText)

console.log(baseText)
i = 0
while i < A.length
    a = A[i]
    a2 = base.apply(a, 0)
    if a2.from != a.from || a2.length != a.length
        console.log('altered op:', a, ' => ', a2)
    console.log(base.text())
    console.log(base.html())
    i++

i = 0
while i < B.length
    b = B[i]
    b2 = base.apply(b, 1)
    if b2.from != b.from || b2.length != b.length
        console.log('altered op:', b, ' => ', b2)
    console.log(base.text())
    console.log(base.html())
    i++
###
