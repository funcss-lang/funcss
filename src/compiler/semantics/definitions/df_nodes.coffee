## The Definition nodes
#
# These nodes represent the AST of the body of the @def at-rule.
#
# *Outputs*
#
# - `grammar()`: returns the generated type (GR tree with semantic functions returning VL trees)
#

ER         = require "../../errors/er_nodes"
SS         = require "../../syntax/ss_nodes"
GR         = require "../../syntax/gr_nodes"
assert     = require "../../helpers/assert"
FS         = require "../fs_nodes"
VL         = require "../values/vl_nodes"

DF = exports

Snd = (_,y) -> y


class DF.Definable

#
# This represents a variable name. TODO it should support dollar signs
class DF.VariableName extends DF.Definable
  constructor: (@value) ->
  grammar: (semantic) ->
    if @value.charAt(0) is "$"
      new GR.CloselyJuxtaposed(
        new GR.DelimLike(new SS.DelimToken('$')),
        new GR.Keyword(@value.substr(1)),
        semantic
      )
    else
      new GR.Keyword(@value, semantic)
  toString: ->
    @value

class DF.FunctionalNotation extends DF.Definable
  constructor: (@name, @argument) ->
  grammar: (semantic) ->
    # TODO finish this
    new GR.FunctionalNotation(@name, @argument,
      semantic
    )
  toString: ->
    "#{@name}(#{@argument})"

class DF.Definition
  constructor: (@definable, @typeName, @rawValue, @block) ->
  grammar: (fs) ->
    console.debug "defining #{@}" if console.debug
    assert.instanceOf {fs}, FS.FunctionalStylesheet
    if @definable instanceof DF.VariableName
      if !@typeName?
        throw new ER.TypeInferenceNotImplemented(@definable)
      type = fs.getType(@typeName)
      if !type?
        throw new ER.UnknownType(@typeName)
      if @rawValue?
        # Here we can parse the value now, create the VL graph and use it for all
        # references of the variable. TODO but what if elem() is used?
        value = type.parse(@rawValue)
        gr = @definable.grammar -> value
      else if @block
        if not type.decodejs?
          throw new ER.DecodingNotSupported type
        value = new VL.JavaScriptFunction type, new VL.Marking(new VL.EmptyValue, {}), @block
        gr = @definable.grammar -> value
      else
        throw new ER.SyntaxError "Definition does not have a body. Please add `= someValue` or `{ return someValue }`"
    else if @definable instanceof DF.FunctionalNotation
      if !@typeName?
        throw new ER.TypeInferenceNotImplemented(@definable)
      type = fs.getType(@typeName)
      if !type?
        throw new ER.UnknownType(@typeName)
      if !@rawValue? and !@block?
        throw new ER.SyntaxError "Definition does not have a body. Please add `= someValue` or `{ return someValue }`"
      gr = @definable.grammar (argument) =>
        # We ensure that the argument has a marking. This does not happens generally
        # for a VDS, but here it is necessary.
        argument = new VL.Marking argument, {} unless argument instanceof VL.Marking

        console.debug "parsed #{@definable.grammar(->)} with argument #{argument}" if console.debug
        if @rawValue?
          fs.pushScope()
          try
            for k,v of argument.marking
              # TODO not only numbers!!
              fs.setType('number', new GR.Keyword(k, ->v))
            # We create a separate VL tree for each invocation of the function so
            # we can bind it with the arguments. TODO optimize this for nullary
            # functions? TODO parse at definition time and bind here?
            value = type.parse(@rawValue)
          finally
            fs.popScope()
          # TODO create the binding between the argument and the value
          value
        else if @block?
          if !type.decodejs?
            throw new ER.TypeError "Cannot convert type <#{@typeName}> back from JavaScript"
          new VL.JavaScriptFunction type, argument, @block
        else
          throw new Error "Internal Error in FunCSS"
    else
      throw new Error "Internal Error in FunCSS: unknown definable type"
    gr.setFs(fs)
    gr

  toString: ->
    "#{@definable}#{if @typeName then ":"+@typeName else ""}#{if @rawValue then " = "+@rawValue else ""}#{if @block then " "+@block else ""}"


    


