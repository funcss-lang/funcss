
#### The Low Level Language nodes
# 
# The nodes defined in this file constitute a tree that represents the most semantical
# representation of the FunCSS stylesheet. It is actually a rule list and a data flow graph.
#
# The basic elements of the tree are Rule and Value. Every Rule associates a Value to a CSS property.
#
# The two outputs of this tree are the `js()` and `ssjs()` methods. Both return a JavaScript
# expression, which, if evaled, return a value for the user-written JS functions and for the 
# CSS, respectively. For example
#

exports.Rule = class Rule
  constructor : (@mediaQuery, @important, @selectorGroup, @prop, @value) ->


exports.Value = class Value

exports.Constant = class Constant extends Value

exports.Keyword = class Constant extends Constant
  constructor: (@value) ->
  js: ->
    JSON.stringify(@value)
  ssjs: ->
    JSON.stringify("#{@value}")

exports.Percentage = class Percentage extends Constant
  constructor: (@value) ->
  js: ->
    JSON.stringify(@value / 100)
  ssjs: ->
    JSON.stringify("#{@value}%")

exports.Number = class Number extends Constant
  constructor: (@value) ->
  js: ->
    JSON.stringify(@value)

exports.EmptyValue = class EmptyValue extends Constant
  js: ->
    "(void 0)"
  ssjs: ->
    JSON.stringify("")

exports.String = class String extends Constant
  js: ->
    JSON.stringify(@value)
  ssjs: ->
    JSON.stringify(@value)


exports.Collection = class Collection extends Value
  constructor: (@value) ->
  delimiter: " "
  unshift: (x)->
    @value.unshift(x)
  js: ->
    "[#{(i.js() for i in @value).join(", ")}]"
  ssjs: ->
    elems = (i.ssjs() for i in @value)
    # We remove the empty values from the token
    elems = (e for e in elems when e != '""')
    if elems.length
      elems.join(" + #{JSON.stringify(@delimiter)} + ")
    else
      JSON.stringify("")

exports.CommaDelimitedCollection = class CommaDelimitedCollection extends Collection
  delimiter: ", "

# A list of values that need to be juxtaposed in a stylesheet.
exports.Juxtaposition = class Juxtaposition extends Collection
    
exports.And = class And extends Collection

exports.InclusiveOr = class InclusiveOr extends Collection

# This class is responsible for using a mapping from an AnnotationRoot object
exports.Marking = class Marking extends Value
  constructor: (@value, @marking) ->
  js: ->
    # The object is wrapped here into `()` to avoid interpreting it as a statement.
    # FIXME the beautifier should handle this later.
    "({#{("#{JSON.stringify(k)}:#{v.js()}" for k,v of @marking).join(", ")}})"
  ssjs: ->
    @value.ssjs()
