## The Definition nodes
#
# These nodes represent the AST of the body of the @def at-rule.
#
# *Outputs*
#
# - `grammar()`: returns the generated type (GR tree with semantic functions returning VL trees)
#

SS = require "../../syntax/ss_nodes"
GR = require "../../syntax/gr_nodes"
assert = require "../../helpers/assert"
FS = require "../fs_nodes"
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
      new GR.Keyword(@value.substr(1), semantic)

class DF.FunctionalNotation extends DF.Definable
  constructor: (@name, @argument) ->
  grammar: (semantic) ->
    # TODO finish this
    new GR.FunctionalNotation(@name, @argument,
      semantic
    )

class DF.Definition
  constructor: (@definable, @type, @rawValue) ->
  grammar: (fs) ->
    assert.instanceOf {fs}, FS.FunctionalStylesheet
    if @definable instanceof DF.VariableName
      # Here we can parse the value now, create the VL graph and use it for all
      # references of the variable.
      value = fs.getType(@type).parse(@rawValue)
      gr = @definable.grammar -> value
    else if @definable instanceof DF.FunctionalNotation
      gr = @definable.grammar ->
        # We create a separate VL tree for each invocation of the function so
        # we can bind it with the arguments. TODO optimize this for nullary
        # functions?
        value = fs.types[@type].parse(@rawValue)
        # TODO create the binding between the argument and the value
        value
    else
      throw new Error "Internal Error in FunCSS: unknown definable type"
    gr.setFs(fs)
    gr


    

