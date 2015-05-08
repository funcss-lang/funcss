## The Definition nodes
#
# These nodes represent the AST of the body of the @def at-rule.
#
# *Outputs*
#
# - `type()`: returns the generated type (GR tree with semantic functions returning VL trees)
#

DF = exports

class DF.Definable

#
# This represents a variable name. TODO it should support dollar signs
class DF.VariableName extends DF.Definable
  constructor: (@value) ->

class DF.FunctionalNotation extends DF.Definable
  constructor: (@name, @argument) ->

class DF.Definition
  constructor: (@definable, @type, @rawValue) ->


