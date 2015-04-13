
#### The Selector nodes


exports.Selector = class Selector


exports.SelectorGroup = class SelectorGroup extends Selector
  constructor: (@value) ->
  toString: ->
    @value.join(", ")

exports.CombinedSelector = class CombinedSelector extends Selector
  constructor: (@head, @combinator, @tail) ->
  toString: ->
    "#{head}#{combinator}#{tail}"

exports.CombinedSelector = class CombinedSelector extends Selector

exports.Combinator = class Combinator extends Selector

exports.SimpleSelectorGroup = class SimpleSelectorGroup extends Selector

exports.SimpleSelector = class SimpleSelector extends Selector

exports.TypeSelector = class TypeSelector extends SimpleSelector
  constructor: (@nodeName) ->
  toString: ->
    "#{@nodeName}"






