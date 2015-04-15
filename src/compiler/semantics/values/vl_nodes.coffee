
#### The Value nodes
# 
# These represent the data flow graph of CSS property values.
#
# The two outputs of this tree are the `jsjs()` and `ssjs()` methods. Both return a JavaScript
# expression, which, if evaled, return a value for the user-written JS functions and for the 
# CSS(OM), respectively.
#

# TODO
exports.escape = escape = (s) -> s

exports.Value = class Value

exports.Constant = class Constant extends Value

exports.Keyword = class Constant extends Constant
  constructor: (@value) ->
  jsjs: ->
    JSON.stringify(@value)
  ssjs: ->
    JSON.stringify("#{escape(@value)}")

exports.Percentage = class Percentage extends Constant
  constructor: (@value) ->
  jsjs: ->
    JSON.stringify(@value / 100)
  ssjs: ->
    JSON.stringify("#{@value}%")

exports.Number = class Number extends Constant
  constructor: (@value) ->
  jsjs: ->
    JSON.stringify(@value)

exports.EmptyValue = class EmptyValue extends Constant
  jsjs: ->
    "(void 0)"
  ssjs: ->
    JSON.stringify("")

exports.String = class String extends Constant
  jsjs: ->
    JSON.stringify(@value)
  ssjs: ->
    JSON.stringify(JSON.stringify(@value))


exports.Collection = class Collection extends Value
  constructor: (@value) ->
  delimiter: " "
  unshift: (x)->
    @value.unshift(x)
  jsjs: ->
    "[#{(i.jsjs() for i in @value).join(", ")}]"
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
  jsjs: ->
    # The object is wrapped here into `()` to avoid interpreting it as a statement.
    # FIXME the beautifier should handle this later.
    "({#{("#{JSON.stringify(k)}:#{v.jsjs()}" for k,v of @marking).join(", ")}})"
  ssjs: ->
    @value.ssjs()

#### Functions
#
exports.FunctionalNotation = class FunctionalNotation extends Value
  constructor: (@name, @arg) ->
  jsjs: ->
    "customFunctions[#{JSON.stringify(@name)}]("+@arg.jsjs()+")"
  ssjs: ->
    JSON.stringify("#{escape(@name)}(") + " + " + @arg.ssjs() + " + " + JSON.stringify(")")



