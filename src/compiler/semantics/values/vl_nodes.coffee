## The Value nodes
# 
# These nodes represent the data flow graph of CSS property values.
#
# *Outputs*:
# - `jsjs()`: returns a string which contains a JavaScript expression. If it is evaled, it returns
#     a JavaScript value representation of the value.
# - `ssjs()`: returns a string which contains a JavaScript expression. If it is evaled, it returns
#     a string which contains the CSS representation of the value.
#

assert = require "../../helpers/assert"
ER     = require "../../errors/er_nodes"

# TODO
VL = exports
VL.escape = escape = (s) -> s

VL.Value = class VL.Value
  toString: ->
    "[#{@constructor.name} #{"#{k}:#{v}" for k,v of @ when @hasOwnProperty(k)}]"

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


class VL.String extends VL.Constant
  constructor: (@value) ->
  jsjs: ->
    JSON.stringify(@value)
  ssjs: ->
    JSON.stringify(JSON.stringify(@value))

class VL.Url extends VL.Constant
  constructor: (@value) ->
  jsjs: ->
    JSON.stringify(@value)
  ssjs: ->
    JSON.stringify("url(#{JSON.stringify(@value)})")

class VL.Dimension extends VL.Constant
  constructor: (@value, @canonicalUnit) ->
  jsjs: ->
    @value.jsjs()
  ssjs: ->
    "#{@value.ssjs()}+#{JSON.stringify(@canonicalUnit)}"

class VL.EmptyValue extends VL.Constant
  jsjs: ->
    "(void 0)"
  ssjs: ->
    JSON.stringify("")

# This is a multiplication of two numbers or numeric values
# The two arguments must have a jsjs() that return a js expression
# that evaluates to a `Number`, and does not have unparenthesized
# operations
class VL.Multiply extends VL.Value
  constructor: (@a, @b) ->
  jsjs: ->
    "(#{@a.jsjs()}*#{@b.jsjs()})"
  ssjs: ->
    "(\"\"+#{@a.jsjs()}*#{@b.jsjs()})"

class VL.Color extends VL.Value
  constructor: ({@r,@g,@b,@a})->
  jsjs: ->
    "{r:#{@r.jsjs()}, g:#{@g.jsjs()}, b:#{@b.jsjs()}#{if @a? then ", a:"+@a.jsjs() else ""}}"
  ssjs: ->
    if @a?
      "'rgba('+Math.round(#{@r.ssjs()})+','+Math.round(#{@g.ssjs()})+','+Math.round(#{@b.ssjs()})+','+Math.round(#{@a.ssjs()})+')'"
    else
      "'rgb('+Math.round(#{@r.ssjs()})+','+Math.round(#{@g.ssjs()})+','+Math.round(#{@b.ssjs()})+')'"


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

# This class is responsible for providing a different value in JavaScript than in 
# SS output. The JavaScript value in this case is always an object.
#
# Also, this class is responsible for providing an argument list for inlined JavaScript
# functions.
class VL.Marking extends VL.Value
  constructor: (@value, @marking) ->
  jsjs: ->
    # The object is wrapped here into `()` to avoid interpreting it as a statement.
    # FIXME the beautifier should handle this later.
    "({#{("#{JSON.stringify(k)}:#{v.jsjs()}" for k,v of @marking).join(", ")}})"
  ssjs: ->
    @value.ssjs()

  # This outputs the formal argument list for an inline function
  formalArguments: ->
    (k for k,v of @marking).join(", ")
  # this outputs the actual argument list for an inline function
  actualArguments: ->
    (v.jsjs() for k,v of @marking).join(", ")
  get: (name) ->
    @marking[name]

  toString: ->
    "[Marking marking:{#{"#{k}:#{v}" for k,v of @marking}} value:#{@value}]"
        

#### Functions
#
class VL.FunctionalNotation extends VL.Value
  constructor: (@name, @arg) ->
  jsjs: ->
    "customFunctions[#{JSON.stringify(@name)}]("+@arg.jsjs()+")"
  ssjs: ->
    JSON.stringify("#{escape(@name)}(") + " + " + @arg.ssjs() + " + " + JSON.stringify(")")

class VL.JavaScriptFunction extends VL.Value
  constructor: (@type, @argument, @block) ->
    if ! @type.decodejs
      throw new ER.DecodingNotSupported type
    assert.instanceOf {@argument}, VL.Marking
    @optimized = @block.toString().match(/^\{\{? ?return ?([()a-zA-Z$_0-9+/*.-][()a-zA-Z$_0-9+/*. -]*) ?;? ?\}\}?$/)?[1]
  jsjs: ->
    if @optimized
      x = (" "+@optimized).replace /([^a-zA-Z0-9$_.])([a-zA-Z$_][a-zA-Z$_0-9]*)/g, (s) =>
        before = s.charAt(0)
        identifier = s.substr(1)
        if (value = @argument.get(identifier))?
          before + value.jsjs()
        else
          before + identifier
      "(#{x})"
    else
      "(function(#{@argument.formalArguments()})#{@block})(#{@argument.actualArguments()})"
  ssjs: ->
    @type.decodejs(@jsjs())


