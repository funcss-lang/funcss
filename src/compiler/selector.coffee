
#### The Selector nodes

exports.SelectorGroup = class SelectorGroup
  @prototype: []
  toString: ->
    @value.join(", ")
exports.Selector = class Selector
exports.CombinedSelector = class CombinedSelector
  constructor: (@head, @combinator, @tail) ->
  toString: ->
    "#{head}#{combinator}#{tail}"
exports.Combinator = class Combinator




