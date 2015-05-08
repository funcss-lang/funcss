# These nodes represent the AST of the body of the @def at-rule.


# The subclasses of the `Pattern` class represent those patterns that can
# be defined. These compile to a GR node.

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


