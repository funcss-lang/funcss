## The Selector nodes
#
# These nodes represent the Selector class
#
# *Outputs*
#
# - `toString()`: returns a string that contains the selector in CSS format
# - `matchjs()`: TODO returns a string that contains a JavaScript expression which evaluates to a
#     boolean: whether the element matches or not 

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

class SL.DescendantCombinator extends SL.Combinator
  constructor: (@a, @b) ->
  toString: ->
    "#{@a} #{@b}"





