
#### The Selector nodes

SL = exports

class SL.Selector


class SL.SelectorGroup extends SL.Selector
  constructor: (@value) ->
  toString: ->
    @value.join(", ")

class SL.CombinedSelector extends SL.Selector
  constructor: (@head, @combinator, @tail) ->
  toString: ->
    "#{head}#{combinator}#{tail}"

class SL.CombinedSelector extends SL.Selector

class SL.Combinator extends SL.Selector

class SL.SimpleSelectorGroup extends SL.Selector

class SL.SimpleSelector extends SL.Selector

class SL.TypeSelector extends SL.SimpleSelector
  constructor: (@nodeName) ->
  toString: ->
    "#{@nodeName}"






