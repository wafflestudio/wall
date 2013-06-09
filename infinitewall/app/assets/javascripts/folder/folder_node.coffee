define ["EventDispatcher", "jquery"], (EventDispatcher, $) ->
  class Node extends EventDispatcher
    constructor: (parent, nodeData, level)->
      super(parent, nodeData, level)

      if parent
        @parent = parent

      @name = nodeData.name
      @id = nodeData.id
      @isSelected = false
      if parent?
        @parentId = parent.id

      @on 'selected', () =>
        console.log('selected', self)
        @isSelected = true
        $(@element).addClass('selected')
        
      @on 'deselected', () =>
        console.log('deselected', this)
        @isSelected = false
        $(@element).removeClass('selected')

      @on 'focus', () =>
        console.log('focus', this)
        if @children?
          for child in @children
            child.trigger('unfocus')
        @trigger('selected', this)
      
      @on 'unfocus', () =>
        console.log('unfocus', this)
        if @children?
          for child in @children
            child.trigger('unfocus')
        
        @trigger('deselected')
        
      @on 'childFocus', (target) =>
        console.log('childFocus', this, target)
        @trigger('deselected')

        if this == target
          return

        for child in @children
          if child == target
            continue
          child.trigger('unfocus')


