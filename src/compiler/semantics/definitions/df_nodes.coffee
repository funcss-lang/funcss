## The Definition nodes
#
# These nodes represent the AST of the body of the @def at-rule.
#
# *Outputs*
#
# - `grammar()`: returns the generated type (GR tree with semantic functions returning VL trees)
#

GR = require "../../syntax/gr_nodes"

DF = exports

Snd = (_,y) -> y


class DF.Definable

#
# This represents a variable name. TODO it should support dollar signs
class DF.VariableName extends DF.Definable
  constructor: (@value) ->
  grammar: (semantic) ->
    new GR.CloselyJuxtaposed(
      new GR.DelimLike(new SS.DelimToken('$')),
      new GR.Keyword(@value),
      semantic
    )

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
    if @definable instanceof DF.VariableName
      # Here we can parse the value now, create the VL graph and use it for all
      # references of the variable.
      value = fs.types[@type].parse(@rawValue)
      @definable.grammar -> value
    else if @definable instanceof DF.FunctionalNotation
      @definable.grammar ->
        # We create a separate VL tree for each invocation of the function so
        # we can bind it with the arguments. TODO optimize this for nullary
        # functions?
        value = fs.types[@type].parse(@rawValue)
        # TODO create the binding between the argument and the value
        value
    else
      throw new Error "Internal Error in FunCSS: unknown definable type"


    


