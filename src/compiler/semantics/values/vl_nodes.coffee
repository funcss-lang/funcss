
#### The Value nodes
# 
# These represent the data flow graph of CSS property values.
#
# The two outputs of this tree are the `jsjs()` and `ssjs()` methods. Both return a JavaScript
# expression, which, if evaled, return a value for the user-written JS functions and for the 
# CSS(OM), respectively.
#

# TODO
VL = exports
VL.escape = escape = (s) -> s

VL.Value = class VL.Value

class VL.Constant extends VL.Value

class VL.Keyword extends VL.Constant
  constructor: (@value) ->
  jsjs: ->
    JSON.stringify(@value)
  ssjs: ->
    JSON.stringify("#{escape(@value)}")

class VL.Percentage extends VL.Constant
  constructor: (@value) ->
  jsjs: ->
    JSON.stringify(@value / 100)
  ssjs: ->
    JSON.stringify("#{@value}%")

class VL.Number extends VL.Constant
  constructor: (@value) ->
  jsjs: ->
    JSON.stringify(@value)
  ssjs: ->
    JSON.stringify("#{@value}")

class VL.EmptyValue extends VL.Constant
  jsjs: ->
    "(void 0)"
  ssjs: ->
    JSON.stringify("")

class VL.String extends VL.Constant
  constructor: (@value) ->
  jsjs: ->
    JSON.stringify(@value)
  ssjs: ->
    JSON.stringify(JSON.stringify(@value))


class VL.Collection extends VL.Value
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

class VL.CommaDelimitedCollection extends VL.Collection
  delimiter: ", "

# A list of values that need to be juxtaposed in a stylesheet.
class VL.Juxtaposition extends VL.Collection
    
class VL.And extends VL.Collection

class VL.InclusiveOr extends VL.Collection

# This class is responsible for using a mapping from an AnnotationRoot object
class VL.Marking extends VL.Value
  constructor: (@value, @marking) ->
  jsjs: ->
    # The object is wrapped here into `()` to avoid interpreting it as a statement.
    # FIXME the beautifier should handle this later.
    "({#{("#{JSON.stringify(k)}:#{v.jsjs()}" for k,v of @marking).join(", ")}})"
  ssjs: ->
    @value.ssjs()

#### Functions
#
class VL.FunctionalNotation extends VL.Value
  constructor: (@name, @arg) ->
  jsjs: ->
    "customFunctions[#{JSON.stringify(@name)}]("+@arg.jsjs()+")"
  ssjs: ->
    JSON.stringify("#{escape(@name)}(") + " + " + @arg.ssjs() + " + " + JSON.stringify(")")



