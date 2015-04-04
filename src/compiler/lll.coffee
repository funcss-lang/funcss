
#### The Low Level Language nodes

exports.Rule = class Rule
  constructor : (@mediaQuery, @important, @selectorGroup, @prop, @value) ->


exports.Value = class Value

exports.Constant = class Constant extends Value

exports.Keyword = class Constant extends Constant
  constructor: (@value) ->
  js: ->
    JSON.stringify(@value)

exports.Percentage = class Percentage extends Constant
  constructor: (@value) ->
  js: ->
    JSON.stringify(@value / 100)

exports.Number = class Number extends Constant
  constructor: (@value) ->
  js: ->
    JSON.stringify(@value)

exports.EmptyValue = class EmptyValue extends Constant
  js: ->
    "(void 0)"

exports.String = class String extends Constant
  js: ->
    JSON.stringify(@value)


exports.Collection = class Collection extends Value
  constructor: (@value) ->
  js: ->
    "[#{(i.js() for i in @value).join(", ")}]"
  unshift: (x)->
    @value.unshift(x)

# A list of values that need to be juxtaposed in a stylesheet.
exports.Juxtaposition = class Juxtaposition extends Collection
    
exports.And = class And extends Collection

exports.InclusiveOr = class InclusiveOr extends Collection

